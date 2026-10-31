import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:sdui_engine/sdui_engine.dart';

import 'model_bytes.dart';
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
final class WebModelSource extends ModelSource {
  WebModelSource({
    Uri? baseUrl,
    this.prefetch = const [],
    this.loadTimeout = const Duration(seconds: 30),
    http.Client? client,
    AssetBundle? bundle,
    int cachedModels = 4,
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

  final ModelBytesCache models;
  late final ViewerPage page;

  /// iOS serves the page from a custom scheme (WKURLSchemeHandler); Android
  /// WebView cannot navigate to one, so it intercepts a reserved https host.
  static final Uri _origin = defaultTargetPlatform == TargetPlatform.android
      ? Uri.parse('https://sdui-model.invalid/')
      : Uri.parse('sdui-model://app/');

  @override
  Future<SduiModelController> controllerFor(ModelRequest request) async =>
      WebModelController(request, this);

  @override
  Future<void> warmUp() async {
    await page.script();
    final loads = [for (final src in prefetch) models.load(src)];
    await _warmWebView();
    await Future.wait(loads);
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
      onLoadResourceWithCustomScheme: (_, request) => _custom(request.url),
      shouldInterceptRequest: (_, request) => _intercept(request.url),
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

  Future<CustomSchemeResponse?> _custom(WebUri url) async {
    final resource = await page.respond(url.uriValue);
    if (resource == null) return null;
    return CustomSchemeResponse(
      data: resource.data,
      contentType: resource.contentType,
    );
  }

  Future<WebResourceResponse?> _intercept(WebUri url) async {
    final resource = await page.respond(url.uriValue);
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
  WebModelController(this._request, this._source) {
    // A load error may land before the engine awaits [initialize].
    _ready.future.ignore();
  }

  final ModelRequest _request;
  final WebModelSource _source;
  final _ready = Completer<void>();
  final _listeners = <VoidCallback>[];
  final _stopwatch = Stopwatch()..start();
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
  Widget buildView() => _view ??= InAppWebView(
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
    onLoadResourceWithCustomScheme: (_, request) =>
        _source._custom(request.url),
    shouldInterceptRequest: (_, request) => _source._intercept(request.url),
    onReceivedError: (_, request, error) {
      if (request.isForMainFrame ?? false) {
        _fail('page failed: ${error.description}');
      }
    },
  );

  void _attach(InAppWebViewController web) {
    _web = web;
    web.addJavaScriptHandler(
      handlerName: 'sduiReady',
      callback: (args) {
        final clips = args.isEmpty ? null : args.first;
        _clips = clips is List
            ? List.unmodifiable(clips.whereType<String>())
            : const [];
        debugPrint(
          '[sdui_model_viewer] ${_request.src} ready in '
          '${_stopwatch.elapsedMilliseconds}ms, clips: $_clips',
        );
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
    debugPrint('[sdui_model_viewer] ${_request.src} failed: $reason');
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
