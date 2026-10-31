import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Loads model files by template `src` and keeps the most recent ones in
/// memory, so a prefetched or revisited model mounts without the network.
///
/// `src` resolution:
/// - `http(s)://...` is fetched as is;
/// - `/path` is resolved against [baseUrl] (e.g. the API origin serving
///   `/assets/...`) and fetched;
/// - anything else is a bundled asset key.
final class ModelBytesCache {
  ModelBytesCache({
    this.baseUrl,
    http.Client? client,
    AssetBundle? bundle,
    this.maxEntries = 4,
  }) : _client = client ?? http.Client(),
       _bundle = bundle;

  final Uri? baseUrl;

  /// How many models stay in memory; the least recently used one is dropped.
  final int maxEntries;

  final http.Client _client;
  final AssetBundle? _bundle;

  /// Insertion-ordered: the first key is the least recently used.
  final _entries = <String, Future<Uint8List>>{};

  /// The network URL for [src], or null when [src] is a bundled asset.
  Uri? resolve(String src) {
    final uri = Uri.tryParse(src);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return uri;
    }
    final base = baseUrl;
    if (src.startsWith('/') && base != null) return base.resolve(src);
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
    final response = await _client.get(url);
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}', url);
    }
    return response.bodyBytes;
  }
}
