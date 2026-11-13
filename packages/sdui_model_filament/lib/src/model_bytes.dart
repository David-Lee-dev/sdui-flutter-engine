import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'model_disk_cache.dart';

/// Loads model files by template `src` and keeps the most recent ones in
/// memory, so a prefetched or revisited model mounts without the network.
///
/// `src` resolution:
/// - `/path` is resolved against [baseUrl] (the gateway origin serving
///   `/assets/...`) and fetched;
/// - `http(s)://...` is fetched as is, but only on [baseUrl]'s origin: the
///   client carries the app's gateway credentials, so another host never
///   receives it and the load fails;
/// - anything else is a bundled asset key.
///
/// [client] is the app's gateway client (e.g. `NemoClient.httpClient`), so
/// models travel the same pinned, authenticated route as other requests.
///
/// With a [disk] cache, fetched models also persist across launches: a
/// stored copy is served at once and revalidated in the background against
/// the server's ETag / Last-Modified, so a file replaced at the same URL
/// shows from the next launch.
final class ModelBytesCache {
  ModelBytesCache({
    required this.baseUrl,
    required this._client,
    this._bundle,
    this.maxEntries = 4,
    this.disk,
  });

  final Uri baseUrl;

  /// Where fetched models persist across launches; null keeps them in
  /// memory only.
  final ModelDiskCache? disk;

  /// How many models stay in memory; the least recently used one is dropped.
  final int maxEntries;

  final http.Client _client;
  final AssetBundle? _bundle;

  /// Insertion-ordered: the first key is the least recently used.
  final _entries = <String, Future<Uint8List>>{};

  /// Disk writes and revalidations still running.
  final _background = <Future<void>>{};

  /// The network URL for [src], or null when [src] is a bundled asset.
  Uri? resolve(String src) {
    final uri = Uri.tryParse(src);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return uri;
    }
    if (src.startsWith('/')) return baseUrl.resolve(src);
    return null;
  }

  /// Whether [src] is loaded or loading.
  bool contains(String src) => _entries.containsKey(src);

  /// The bytes of [src], loading them on first use. A failed load is not
  /// cached, so the next call retries.
  Future<Uint8List> load(String src) {
    final cached = _entries.remove(src);
    if (cached != null) {
      _entries[src] = cached;
      return cached;
    }
    final future = _fetch(src);
    _entries[src] = future;
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
    future.ignore();
    future.then<void>(
      (_) {},
      onError: (Object _) {
        if (identical(_entries[src], future)) _entries.remove(src);
      },
    );
    return future;
  }

  Future<Uint8List> _fetch(String src) async {
    final url = resolve(src);
    if (url == null) {
      final data = await (_bundle ?? rootBundle).load(src);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }
    if (url.origin != baseUrl.origin) {
      throw http.ClientException('not on the gateway origin $baseUrl', url);
    }
    final stored = await disk?.read(url);
    if (stored != null) {
      _inBackground(_revalidate(url, stored));
      return stored.bytes;
    }
    final response = await _client.get(url);
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}', url);
    }
    _inBackground(_store(url, response));
    return response.bodyBytes;
  }

  /// Asks the server whether [stored] is current; a changed file replaces it
  /// for the next launch. Offline, the stored copy stays.
  Future<void> _revalidate(Uri url, StoredModel stored) async {
    try {
      final response = await _client.get(
        url,
        headers: {
          'If-None-Match': ?stored.etag,
          'If-Modified-Since': ?stored.lastModified,
        },
      );
      if (response.statusCode == 200) await _store(url, response);
    } on Object {
      // Offline or failing: keep serving the stored copy.
    }
  }

  Future<void> _store(Uri url, http.Response response) async => disk?.write(
    url,
    response.bodyBytes,
    etag: response.headers['etag'],
    lastModified: response.headers['last-modified'],
  );

  void _inBackground(Future<void> work) {
    _background.add(work);
    unawaited(work.whenComplete(() => _background.remove(work)));
  }

  /// Completes once disk writes and revalidations started so far finish.
  @visibleForTesting
  Future<void> settle() async {
    while (_background.isNotEmpty) {
      await Future.wait([..._background]);
    }
  }
}
