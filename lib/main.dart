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
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;
  String? _tip;

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
          ],
        ),
      ),
    );
  }
}
