import '../contract/external_command.dart';

/// A vendor or platform integration the engine calls through external
/// commands.
///
/// A service owns one integration (an ads SDK, support chat, social login,
/// image upload, ...) and declares the template-callable commands it
/// contributes: each [ExternalCommand.type] becomes a `{ _type: ... }` action
/// command. What the commands are named and what they do is entirely the
/// implementor's — the engine only routes the types.
///
/// Wire at boot:
/// ```dart
/// Sdui.initialize(services: [SupportChatService(), AdsService()]);
/// ```
/// [onRegister] runs once per service before the engine catalog freezes —
/// SDK initialization belongs there.
///
/// A standalone command without SDK setup still ships as a service — a
/// one-command [commands] list with the default no-op [onRegister].
abstract class SduiService {
  const SduiService();

  /// The commands this service contributes to the template language.
  List<ExternalCommand> get commands;

  /// One-time setup hook, called before the engine catalog freezes.
  void onRegister() {}
}
