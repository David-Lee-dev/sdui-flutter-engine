/// Filament renderer for the sdui_engine `model_3d` widget.
///
/// Install [FilamentModel3dSource] as `Sdui.initialize(model3dSource: ...)`.
library;

export 'package:sdui_model_support/sdui_model_support.dart'
    show FrameStats, ModelBytesCache, ModelDebugOverlay, ModelLoadStats;

export 'src/filament_model_3d_source.dart'
    show FilamentModel3dController, FilamentModel3dSource;
