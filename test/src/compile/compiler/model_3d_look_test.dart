import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/ir/model/ui_node.dart';

void main() {
  test('tap feature is accepted and declare only', () {
    for (final declared in [true, false]) {
      expect(
        () => TemplateCompiler.buildRoot(
          UiNode(
            type: 'model_3d',
            props: const {'src': 'a.glb', 'on_tap_model': 'picked'},
            reserved: declared
                ? const {
                    '_requires': ['model_3d_tap_v1'],
                  }
                : const {},
          ),
        ),
        returnsNormally,
      );
    }
  });

  test('removed look props are tolerated', () {
    expect(
      () => TemplateCompiler.buildRoot(
        UiNode(
          type: 'model_3d',
          props: const {
            'src': 'a.glb',
            'shading': 'unlit',
            'outline': {'width': 2},
            'highlight_on_tap': {'duration': 200},
          },
        ),
      ),
      returnsNormally,
    );
  });

  test('removed shading feature is rejected', () {
    expect(
      () => TemplateCompiler.buildRoot(
        UiNode(
          type: 'model_3d',
          props: const {'src': 'a.glb'},
          reserved: const {
            '_requires': ['model_3d_shading_v1'],
          },
        ),
      ),
      throwsA(
        isA<InvalidTemplateException>().having(
          (error) => error.message,
          'message',
          contains('unknown "_requires" feature "model_3d_shading_v1"'),
        ),
      ),
    );
  });

  test('motion feature accepted and declare only', () {
    for (final declared in [true, false]) {
      expect(
        () => TemplateCompiler.buildRoot(
          UiNode(
            type: 'model_3d',
            props: const {
              'src': 'a.glb',
              'morphs': {'smile': 1},
              'blink': true,
              'look_at': {'target': 'camera'},
              'layer': {'clip': 'Wave'},
            },
            reserved: declared
                ? const {
                    '_requires': ['model_3d_motion_v1'],
                  }
                : const {},
          ),
        ),
        returnsNormally,
      );
    }
  });

  test('outfit feature is accepted and declare only', () {
    for (final declared in [true, false]) {
      expect(
        () => TemplateCompiler.buildRoot(
          UiNode(
            type: 'model_3d',
            props: const {
              'src': 'a.glb',
              'outfit': {
                'show': ['shirt'],
              },
            },
            reserved: declared
                ? const {
                    '_requires': ['model_3d_outfit_v1'],
                  }
                : const {},
          ),
        ),
        returnsNormally,
      );
    }
  });

  test('scene feature is accepted and declare only', () {
    for (final declared in [true, false]) {
      expect(
        () => TemplateCompiler.buildRoot(
          UiNode(
            type: 'model_3d',
            props: const {
              'src': 'a.glb',
              'scene': [
                {'src': 'planet.glb'},
              ],
              'camera': {'target': 'Head'},
              'controls': {'pan': true},
            },
            reserved: declared
                ? const {
                    '_requires': ['model_3d_scene_v1'],
                  }
                : const {},
          ),
        ),
        returnsNormally,
      );
    }
  });

  test('look feature is accepted and declare only', () {
    for (final declared in [true, false]) {
      expect(
        () => TemplateCompiler.buildRoot(
          UiNode(
            type: 'model_3d',
            props: const {
              'src': 'a.glb',
              'quality': 'high',
              'shadow': 'contact',
            },
            reserved: declared
                ? const {
                    '_requires': ['model_3d_look_v1'],
                  }
                : const {},
          ),
        ),
        returnsNormally,
      );
    }
  });
}
