import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../core/platform/platform.dart';
import '../services/device_service.dart';
import '../services/notification_service.dart';
import '../services/websocket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WebSocketService _webSocketService =
      WebSocketService(url: AppConfig.production.websocketUrl);
  String _status = '未连接';
  String _deviceInfo = '获取设备信息中...';

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final info = await DeviceService.getDeviceDescriptor();
    setState(() {
      _deviceInfo = '${info.platform} / ${info.model} / ${info.version}';
    });
  }

  Future<void> _connectWebSocket() async {
    _webSocketService.connect(
      onMessage: (message) {
        setState(() {
          _status = '收到消息: $message';
        });
        _showNotification(
          title: '收到 WebSocket 消息',
          body: message.toString(),
          sound: AppConfig.production.soundAsset,
        );
      },
      onError: (error) {
        setState(() {
          _status = '连接错误: $error';
        });
      },
      onDone: () {
        setState(() {
          _status = '连接已关闭';
        });
      },
    );

    setState(() {
      _status = '已连接';
    });
  }

  Future<void> _showNotification(
      {required String title,
      required String body,
      required String sound}) async {
    await NotificationService.show(
      title: title,
      body: body,
      sound: sound,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('设备信息: $_deviceInfo'),
            const SizedBox(height: 12),
            Text('WebSocket 状态: $_status'),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _connectWebSocket,
              icon: const Icon(Icons.wifi),
              label: const Text('连接 WebSocket'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                await _showNotification(
                  title: '通知示例',
                  body: '当前平台: ${AppPlatformInfo.detect().platform.name}',
                  sound: AppConfig.production.soundAsset,
                );
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('发送通知'),
            ),
          ],
        ),
      ),
    );
  }
}
