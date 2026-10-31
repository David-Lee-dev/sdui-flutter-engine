import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_model_support/sdui_model_support.dart';

import 'viewer_page.dart';

/// A [ModelSource] that renders each `model` in a transparent webview
/// running Google's `<model-viewer>` (bundled, no CDN).
///
/// ```dart
/// Sdui.initialize(
///   modelSource: WebModelSource(
///     baseUrl: Uri.parse(apiUrl),       // resolves `/assets/...` srcs
///     prefetch: ['/assets/character.glb'],
///   ),
///   ...
/// );
/// ```
///
/// Model bytes load in Dart ([ModelBytesCache]) and reach the page through a
/// same-origin scheme the webview hands back to Dart, so [prefetch] and
/// revisits skip the network. [warmUp] loads the viewer once in a headless
/// webview so the first visible mount does not pay the engine start-up.
///
/// [debugOverlay] (default: `--dart-define=SDUI_MODEL_DEBUG=true`) paints each
/// view's load timeline, app memory and frame times over it for measurement.
final class WebModelSource extends ModelSource {
  WebModelSource({
    Uri? baseUrl,
    this.prefetch = const [],
    this.loadTimeout = const Duration(seconds: 30),
    http.Client? client,
    AssetBundle? bundle,
    int cachedModels = 4,
    this.debugOverlay = const bool.fromEnvironment('SDUI_MODEL_DEBUG'),
  }) : models = ModelBytesCache(
         baseUrl: baseUrl,
         client: client,
         bundle: bundle,
         maxEntries: cachedModels,
       ) {
    page = ViewerPage(origin: _origin, models: models, bundle: bundle);
  }

  /// Model srcs loaded into memory during [warmUp].
  final List<String> prefetch;

  /// How long a model may take to load before the widget falls back to its
  /// poster.
  final Duration loadTimeout;

  /// Paints [ModelDebugOverlay] over every view.
  final bool debugOverlay;

  final ModelBytesCache models;
  late final ViewerPage page;

  int _mounts = 0;
  int? _warmUpMs;

  /// iOS serves the page from a custom scheme (WKURLSchemeHandler); Android
  /// WebView cannot navigate to one, so it intercepts a reserved https host.
  static final Uri _origin = defaultTargetPlatform == TargetPlatform.android
      ? Uri.parse('https://sdui-model.invalid/')
      : Uri.parse('sdui-model://app/');

  @override
  Future<SduiModelController> controllerFor(ModelRequest request) async =>
      WebModelController(request, this);

  ModelLoadStats _statsFor(String src) => ModelLoadStats(
    src: src,
    mount: ++_mounts,
    warmUpMs: _warmUpMs,
    renderer: 'web',
    outOfProcess: true,
  );

  @override
  Future<void> warmUp() async {
    final clock = Stopwatch()..start();
    await page.script();
    final loads = [for (final src in prefetch) models.load(src)];
    await _warmWebView();
    await Future.wait(loads);
    _warmUpMs = clock.elapsedMilliseconds;
    debugPrint('[sdui_model_viewer] warm-up took ${_warmUpMs}ms');
  }

  /// Loads the viewer script in a throwaway headless webview so the web
  /// engine process and script parse are warm before the first mount.
  Future<void> _warmWebView() async {
    final loaded = Completer<void>();
    final headless = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(page.pageUrl(src: '').toString()),
      ),
      initialSettings: settings(),
      onLoadResourceWithCustomScheme: (_, request) async =>
          _custom(await page.respond(request.url.uriValue)),
      shouldInterceptRequest: (_, request) async =>
          _intercept(await page.respond(request.url.uriValue)),
      onLoadStop: (_, _) {
        if (!loaded.isCompleted) loaded.complete();
      },
      onReceivedError: (_, _, _) {
        if (!loaded.isCompleted) loaded.complete();
      },
    );
    try {
      await headless.run();
      await loaded.future.timeout(const Duration(seconds: 10));
    } on TimeoutException {
      // Warm-up is best effort.
    } finally {
      await headless.dispose();
    }
  }

  /// Webview settings shared by every viewer.
  InAppWebViewSettings settings() => InAppWebViewSettings(
    resourceCustomSchemes: [if (_origin.scheme != 'https') _origin.scheme],
    useShouldInterceptRequest: _origin.scheme == 'https',
    transparentBackground: true,
    disableContextMenu: true,
    supportZoom: false,
    disallowOverScroll: true,
    verticalScrollBarEnabled: false,
    horizontalScrollBarEnabled: false,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    isInspectable: kDebugMode,
  );

  static CustomSchemeResponse? _custom(ViewerResource? resource) {
    if (resource == null) return null;
    return CustomSchemeResponse(
      data: resource.data,
      contentType: resource.contentType,
    );
  }

  static WebResourceResponse? _intercept(ViewerResource? resource) {
    if (resource == null) return null;
    return WebResourceResponse(
      data: resource.data,
      contentType: resource.contentType,
      contentEncoding: 'utf-8',
      statusCode: 200,
      reasonPhrase: 'OK',
      headers: {'Access-Control-Allow-Origin': '*'},
    );
  }
}

/// Drives one `<model-viewer>` webview for the engine's `model` widget.
final class WebModelController implements SduiModelController {
  WebModelController(this._request, this._source)
    : stats = _source._statsFor(_request.src) {
    // A load error may land before the engine awaits [initialize].
    _ready.future.ignore();
  }

  final ModelRequest _request;
  final WebModelSource _source;
  final _ready = Completer<void>();
  final _listeners = <VoidCallback>[];

  /// This view's load timeline, also painted when
  /// [WebModelSource.debugOverlay] is on.
  final ModelLoadStats stats;
  InAppWebViewController? _web;
  Widget? _view;
  List<String> _clips = const [];
  ModelPlayback _playback = const ModelPlayback();
  bool _disposed = false;

  @override
  Future<void> initialize() => _ready.future.timeout(_source.loadTimeout);

  @override
  List<String> get clips => _clips;

  @override
  ModelPlayback get playback => _playback;

  @override
  Future<void> play(
    String clip, {
    required bool loop,
    Duration crossfade = Duration.zero,
  }) async {
    _update(
      ModelPlayback(
        clip: clip,
        isPlaying: true,
        completions: _playback.completions,
      ),
    );
    await _web?.evaluateJavascript(
      source:
          'sduiPlay(${jsonEncode(clip)}, $loop, ${crossfade.inMilliseconds})',
    );
  }

  @override
  Future<void> stop() async {
    await _web?.evaluateJavascript(source: 'sduiStop()');
  }

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  @override
  Widget buildView() => _view ??= _source.debugOverlay
      ? ModelDebugOverlay(stats: stats, child: _webView())
      : _webView();

  Widget _webView() => InAppWebView(
    initialUrlRequest: URLRequest(
      url: WebUri(
        _source.page
            .pageUrl(
              src: _request.src,
              interactive: _request.interactive,
              autoRotate: _request.autoRotate,
            )
            .toString(),
      ),
    ),
    initialSettings: _source.settings(),
    onWebViewCreated: _attach,
    onLoadStop: (_, _) => _mark('page'),
    onLoadResourceWithCustomScheme: (_, request) async =>
        WebModelSource._custom(await _serve(request.url)),
    shouldInterceptRequest: (_, request) async =>
        WebModelSource._intercept(await _serve(request.url)),
    onReceivedError: (_, request, error) {
      if (request.isForMainFrame ?? false) {
        _fail('page failed: ${error.description}');
      }
    },
  );

  /// Serves a page resource, timing the model bytes.
  Future<ViewerResource?> _serve(WebUri url) async {
    final uri = url.uriValue;
    if (uri.path != '/model') return _source.page.respond(uri);
    final cached = _source.models.contains(uri.queryParameters['src'] ?? '');
    final started = stats.elapsedMs;
    final resource = await _source.page.respond(uri);
    if (resource != null && !_disposed) {
      stats.served(
        bytes: resource.data.length,
        cached: cached,
        ms: stats.elapsedMs - started,
      );
    }
    return resource;
  }

  void _mark(String label) {
    if (!_disposed) stats.mark(label);
  }

  void _attach(InAppWebViewController web) {
    _web = web;
    _mark('webview');
    web.addJavaScriptHandler(
      handlerName: 'sduiReady',
      callback: (args) {
        final clips = args.isEmpty ? null : args.first;
        _clips = clips is List
            ? List.unmodifiable(clips.whereType<String>())
            : const [];
        _mark('ready');
        debugPrint('[sdui_model_viewer] ${stats.summary()}, clips: $_clips');
        if (!_ready.isCompleted) _ready.complete();
      },
    );
    web.addJavaScriptHandler(
      handlerName: 'sduiError',
      callback: (args) => _fail(args.isEmpty ? 'error' : '${args.first}'),
    );
    web.addJavaScriptHandler(
      handlerName: 'sduiFinished',
      callback: (_) => _update(
        ModelPlayback(
          clip: _playback.clip,
          isPlaying: false,
          completions: _playback.completions + 1,
        ),
      ),
    );
    web.addJavaScriptHandler(
      handlerName: 'sduiPlaying',
      callback: (args) {
        final playing = args.isNotEmpty && args.first == true;
        if (playing == _playback.isPlaying) return;
        _update(
          ModelPlayback(
            clip: _playback.clip,
            isPlaying: playing,
            completions: _playback.completions,
          ),
        );
      },
    );
  }

  void _fail(String reason) {
    if (!_disposed) stats.fail(reason);
    debugPrint('[sdui_model_viewer] ${stats.summary()}');
    if (!_ready.isCompleted) _ready.completeError(StateError(reason));
  }

  void _update(ModelPlayback playback) {
    if (_disposed) return;
    _playback = playback;
    for (final listener in [..._listeners]) {
      listener();
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _listeners.clear();
    _web = null;
  }
}
