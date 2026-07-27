import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketService({required this.url});

  final String url;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  bool get isConnected => _channel != null;

  void connect(
      {void Function(dynamic message)? onMessage,
      void Function(Object error)? onError,
      void Function()? onDone}) {
    if (isConnected) {
      return;
    }

    _channel = WebSocketChannel.connect(Uri.parse(url));
    _subscription = _channel!.stream.listen(
      (message) => onMessage?.call(message),
      onError: onError,
      onDone: onDone,
    );
  }

  void send(String message) {
    if (!isConnected) {
      throw StateError('WebSocket 未连接');
    }

    _channel?.sink.add(message);
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }
}
