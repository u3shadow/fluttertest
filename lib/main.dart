import 'package:vibration/vibration.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    } else {
      setState(() {
        _tip = '当前设备不支持震动';
      });
    }
  }
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;
  String? _tip;
  String? _deviceInfo;
  Future<void> _showDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    String info = '';
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        info = 'Android ${androidInfo.version.release}\nModel: ${androidInfo.model}\nBrand: ${androidInfo.brand}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        info = 'iOS ${iosInfo.systemVersion}\nModel: ${iosInfo.utsname.machine}\nName: ${iosInfo.name}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfoPlugin.windowsInfo;
        info = 'Windows ${windowsInfo.productName} ${windowsInfo.releaseId}';
      } else {
        info = 'Unknown platform';
      }
    } catch (e) {
      info = '获取设备信息失败: $e';
    }
    setState(() {
      _deviceInfo = info;
    });
  }

  Future<void> _takePhoto() async {
    if (_isPicking) return;
    setState(() {
      _isPicking = true;
      _tip = '正在打开相机，请稍候...';
    });
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _tip = null;
          _imageFile = File(photo.path);
        });
      } else {
        setState(() {
          _tip = '已取消拍照';
        });
      }
    } catch (e) {
      setState(() {
        _tip = '拍照出错，请重试';
      });
    } finally {
      setState(() {
        _isPicking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageFile != null)
              Image.file(_imageFile!, width: 200, height: 200, fit: BoxFit.cover),
            if (_tip != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_tip!, style: TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: _takePhoto,
              child: const Text('拍照'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showDeviceInfo,
              child: const Text('显示设备信息'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _vibrate,
              child: const Text('震动手机'),
            ),
            if (_deviceInfo != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_deviceInfo!),
              ),
          ],
        ),
      ),
    );
  }
}
