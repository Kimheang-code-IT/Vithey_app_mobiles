import 'package:aub_connect_app/data/models/chat_stomp_payload.dart';
import 'package:aub_connect_app/data/services/chat_stomp_service.dart';

/// Routes STOMP payloads to repository callbacks.
class ChatRealtimeHub {
  ChatRealtimeHub(this._stomp);

  final ChatStompService _stomp;
  void Function(ChatStompPayload payload)? onEvent;

  void start() {
    _stomp.events.listen((event) => onEvent?.call(event));
  }
}
