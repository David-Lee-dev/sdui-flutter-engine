import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// A model file kept on disk, with the validators its server sent.
final class StoredModel {
  const StoredModel(this.bytes, {this.etag, this.lastModified});

  final Uint8List bytes;
  final String? etag;
  final String? lastModified;
}

/// Keeps downloaded model files on disk, so a model seen once opens again
/// without the network, across launches.
///
/// Files are keyed by URL. [ModelBytesCache] serves a stored copy at once
/// and revalidates it in the background, so a file replaced at the same URL
/// shows from the next load. The least recently used files go once the total
/// passes [maxBytes]. Every failure (no directory, a full disk, an unreadable
/// file) is only a miss: loads fall back to the network.
final class ModelDiskCache {
  /// Stores under [directory], by default `sdui_models` in the app's cache
  /// directory, which the OS may clear when storage runs low.
  ModelDiskCache({
    FutureOr<Directory> Function()? directory,
    this.maxBytes = 64 << 20,
  }) : _directory = directory ?? _appCache;

  /// Total size the stored files may take.
  final int maxBytes;

  final FutureOr<Directory> Function() _directory;
  Future<Directory?>? _root;

  static Future<Directory> _appCache() async =>
      Directory('${(await getApplicationCacheDirectory()).path}/sdui_models');

  Future<Directory?> get _dir => _root ??= () async {
    try {
      final dir = await _directory();
      await dir.create(recursive: true);
      return dir;
    } on Object {
      return null;
    }
  }();

  /// The stored copy of [url], or null.
  Future<StoredModel?> read(Uri url) async {
    try {
      final dir = await _dir;
      if (dir == null) return null;
      final file = _model(dir, url);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return null;
      // Last-modified time orders eviction: a read keeps the file. Some
      // file systems keep whole seconds here, so recency is per second.
      await file.setLastModified(DateTime.now());
      final meta = await _readMeta(dir, url);
      return StoredModel(
        bytes,
        etag: meta['etag'],
        lastModified: meta['last_modified'],
      );
    } on Object {
      return null;
    }
  }

  /// Stores [bytes] for [url], replacing any older copy.
  Future<void> write(
    Uri url,
    Uint8List bytes, {
    String? etag,
    String? lastModified,
  }) async {
    try {
      final dir = await _dir;
      if (dir == null) return;
      // The model before its validators: interrupted between the two, a new
      // model pairs with old validators and is refetched once, never an old
      // model with new ones that the server would confirm.
      await _replace(_model(dir, url), bytes);
      await _replace(
        _meta(dir, url),
        utf8.encode(
          jsonEncode({'etag': ?etag, 'last_modified': ?lastModified}),
        ),
      );
      await _trim(dir);
    } on Object {
      // A cache that cannot write only misses.
    }
  }

  /// Marks [url]'s copy as just used, so eviction keeps it.
  Future<void> touch(Uri url) async {
    try {
      final dir = await _dir;
      if (dir != null) await _model(dir, url).setLastModified(DateTime.now());
    } on Object {
      // Nothing stored.
    }
  }

  /// Writes beside [file] and renames over it, so a reader never sees a
  /// partial file.
  static Future<void> _replace(File file, List<int> bytes) async {
    final temp = File('${file.path}.${DateTime.now().microsecondsSinceEpoch}');
    await temp.writeAsBytes(bytes, flush: true);
    await temp.rename(file.path);
  }

  Future<Map<String, String>> _readMeta(Directory dir, Uri url) async {
    try {
      final meta = jsonDecode(await _meta(dir, url).readAsString());
      return {
        for (final MapEntry(:key, :value) in (meta as Map).entries)
          if (value is String) key as String: value,
      };
    } on Object {
      return const {};
    }
  }

  /// Deletes the least recently used models past [maxBytes], keeping the
  /// newest even when it alone is larger.
  Future<void> _trim(Directory dir) async {
    final models = <(File, FileStat)>[
      await for (final entry in dir.list())
        if (entry is File && entry.path.endsWith('.model'))
          (entry, await entry.stat()),
    ]..sort((a, b) => b.$2.modified.compareTo(a.$2.modified));
    var total = 0;
    for (final (i, (file, stat)) in models.indexed) {
      total += stat.size;
      if (i == 0 || total <= maxBytes) continue;
      await file.delete();
      final meta = File('${file.path.substring(0, file.path.length - 6)}.json');
      if (await meta.exists()) await meta.delete();
    }
  }

  File _model(Directory dir, Uri url) => File('${dir.path}/${key(url)}.model');

  File _meta(Directory dir, Uri url) => File('${dir.path}/${key(url)}.json');

  /// A file-name-safe key for [url] (64-bit FNV-1a, hex).
  static String key(Uri url) {
    // The FNV offset basis 0xcbf29ce484222325, as a signed 64-bit int.
    var hash = -0x340d631b7bdddcdb;
    for (final unit in utf8.encode(url.toString())) {
      hash = (hash ^ unit) * 0x100000001b3;
    }
    // Two unsigned halves: a 64-bit int has no unsigned form to print.
    String half(int bits) => bits.toRadixString(16).padLeft(8, '0');
    return half(hash >>> 32) + half(hash & 0xffffffff);
  }
}
