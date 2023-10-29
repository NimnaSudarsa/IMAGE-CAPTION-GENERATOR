import 'package:camera/camera.dart';
import 'package:flutter/material.dart';


late CameraController controller;

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late List<CameraDescription> cameras;

  @override
  void initState() {
    startCamera();
    super.initState();
  }

  void startCamera() async {
    cameras = await availableCameras();

    controller = CameraController(cameras[0], ResolutionPreset.ultraHigh, enableAudio: false);

    await controller.initialize().then((value) {
      if(!mounted){
        return;
      }

      setState(() {});
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }else {
      return CameraPreview(controller);
    }
  }
}