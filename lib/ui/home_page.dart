import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../core/config/app_config.dart';
import '../core/platform/platform.dart';
import '../services/device_service.dart';
import '../services/notification_service.dart';
import '../services/push/jpush_service.dart';
import '../services/push_service.dart';
import '../services/websocket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppPlatformInfo _platformInfo = AppPlatformInfo.detect();
  WebSocketService? _webSocketService;
  PushService? _pushService;
  final TextEditingController _urlController = TextEditingController(
    text: AppConfig.production.websocketUrl,
  );
  int _currentIndex = 0;
  String _status = '未连接';
  String _deviceInfo = '获取设备信息中...';
  String? _fcmToken;
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
    if (_platformInfo.isMobile) {
      _initPushService();
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _webSocketService?.disconnect();
    super.dispose();
  }

  Future<void> _loadDeviceInfo() async {
    final info = await DeviceService.getDeviceDescriptor();
    setState(() {
      _deviceInfo = '${info.platform} / ${info.model} / ${info.version}';
    });
  }

  // ===== WebSocket (Desktop) =====
  Future<void> _connectWebSocket() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _status = '请输入 WebSocket 地址');
      return;
    }
    _webSocketService?.disconnect();
    _webSocketService = WebSocketService(url: url);
    _webSocketService!.connect(
      onMessage: (message) {
        setState(() {
          _status = '收到消息: $message';
          _messages.insert(0, message.toString());
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

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _status = '请输入 WebSocket 地址');
      return;
    }
    setState(() => _status = '测试中...');
    final channel = WebSocketChannel.connect(Uri.parse(url));
    try {
      await channel.ready.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('连接超时'),
      );
      setState(() => _status = '测试连接成功');
    } catch (e) {
      setState(() => _status = '测试连接失败: $e');
    } finally {
      await channel.sink.close();
    }
  }

  // ===== 极光推送 (Mobile - 国内) =====
  Future<void> _initPushService() async {
    _pushService = JPushService(
      appKey: AppConfig.production.jpushAppKey,
      channel: AppConfig.production.jpushChannel,
      debug: true,
    );
    _pushService!.onMessageReceived((message) {
      setState(() {
        _status = '收到推送: ${message.title}';
        _messages.insert(0, '${message.title}: ${message.body}');
      });
      _showNotification(
        title: message.title,
        body: message.body,
        sound: AppConfig.production.soundAsset,
      );
    });
    try {
      await _pushService!.initialize();
      final token = await _pushService!.getToken();
      setState(() {
        _status = 'JPush 已初始化';
        _fcmToken = token;
      });
    } catch (e) {
      setState(() => _status = 'JPush 初始化失败: $e');
    }
  }

  Future<void> _refreshFcmToken() async {
    try {
      final token = await _pushService?.getToken();
      setState(() => _fcmToken = token);
      if (token != null) {
        _showSnack('Token: $token');
      }
    } catch (e) {
      _showSnack('获取 Token 失败: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildListTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '列表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }

  Widget _buildListTab() {
    if (_messages.isEmpty) {
      return const Center(
        child: Text('暂无消息'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _messages.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final message = _messages[index];
        return ListTile(
          leading: const Icon(Icons.notifications),
          title: Text('消息 #${_messages.length - index}'),
          subtitle: Text(message),
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('设备信息: $_deviceInfo'),
          const SizedBox(height: 8),
          Text('平台: ${_platformInfo.platform.name}'),
          const SizedBox(height: 8),
          Text('状态: $_status'),
          const SizedBox(height: 20),
          if (_platformInfo.isDesktop) ..._buildDesktopSettings(),
          if (_platformInfo.isMobile) ..._buildMobileSettings(),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              await _showNotification(
                title: '通知示例',
                body: '当前平台: ${_platformInfo.platform.name}',
                sound: AppConfig.production.soundAsset,
              );
            },
            icon: const Icon(Icons.notifications_active),
            label: const Text('发送通知'),
          ),
        ],
      ),
    );
  }

  // ===== 平台相关设置组件 =====
  List<Widget> _buildDesktopSettings() {
    return [
      TextField(
        controller: _urlController,
        decoration: const InputDecoration(
          labelText: 'WebSocket 地址',
          hintText: 'wss://example.com/ws',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.url,
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _testConnection,
              icon: const Icon(Icons.science),
              label: const Text('测试'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: _connectWebSocket,
              icon: const Icon(Icons.wifi),
              label: const Text('连接'),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildMobileSettings() {
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '极光推送 (JPush)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '国内 Android/iOS 通过极光推送接收消息,自动集成小米/华为/OPPO/vivo 等厂商通道。',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'RegistrationId: ${_fcmToken ?? "未获取"}',
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _refreshFcmToken,
              icon: const Icon(Icons.refresh),
              label: const Text('刷新 Token'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                if (_fcmToken != null) {
                  _showSnack('已记录 Token,请配置服务端推送');
                } else {
                  _showSnack('Token 不存在,请先初始化');
                }
              },
              icon: const Icon(Icons.copy),
              label: const Text('显示 Token'),
            ),
          ),
        ],
      ),
    ];
  }
}
