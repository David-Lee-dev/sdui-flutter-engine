/// Filament renderer for the sdui_engine `model` widget.
///
/// Install [FilamentModelSource] as `Sdui.initialize(modelSource: ...)`.
library;

export 'package:sdui_model_support/sdui_model_support.dart'
    show FrameStats, ModelBytesCache, ModelDebugOverlay, ModelLoadStats;

export 'src/filament_model_source.dart'
    show FilamentModelController, FilamentModelSource;
