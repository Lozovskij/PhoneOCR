import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_ocr/helpers.dart';
import 'package:phone_ocr/result_screen.dart';

import 'result_dialog.dart';

void main() {
   WidgetsFlutterBinding.ensureInitialized();
   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone OCR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  PermissionStatus _cameraPermissionStatus = PermissionStatus.denied;
  late final Future<void> _permissionFuture;
  CameraController? _cameraController;
  final textRecognizer = TextRecognizer();

  bool showFocusCircle = false;
  double x = 0;
  double y = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _permissionFuture = _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _permissionFuture,
      builder: (context, snapshot) {
        return SafeArea(
          child: Stack(
            children: [
              if (_cameraPermissionStatus == PermissionStatus.granted)
                // Show the camera feed behind everything
                FutureBuilder<List<CameraDescription>>(
                  future:
                      availableCameras(), //TODO is it right though? I wouldn't place it in there (FUTURE PROBLEM)
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _initCameraController(snapshot.data!);
                      return  CameraPreview(_cameraController!);
                    } else {
                      return const LinearProgressIndicator();
                    }
                  },
                ),
              if (_cameraPermissionStatus == PermissionStatus.granted)
                Scaffold(
                  // Set the background to transparent so you can see the camera preview
                  backgroundColor: Colors.transparent,
                  body: Column(
                    children: [
                      Expanded(
                         child: GestureDetector(
                          onTapUp: (details) {
                            _onTap(details);
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Stack(
                            children: [
                              if (showFocusCircle)
                                Positioned(
                                  top: y - 37,
                                  left: x - 37,
                                  child: Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 3),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.radio_button_checked),
                            tooltip: 'Select phone numbers',
                            onPressed: _takePhotoAndProcess,
                            color: Colors.white,
                            iconSize: 70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_cameraPermissionStatus == PermissionStatus.denied ||
                  _cameraPermissionStatus == PermissionStatus.permanentlyDenied)
                Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(30.0),
                          child: SizedBox(
                            width: 300,
                            child: Text(
                              'Press "Scan image". Please note that in order to use the app, you must provide permissions to use the camera',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            var status = await Permission.camera.status;
                            if (status.isGranted) {
                              setState(() => _cameraPermissionStatus = status);
                            }
                            if (status.isDenied) {
                              await _requestCameraPermission();
                              status = await Permission.camera.status;
                              setState(() => _cameraPermissionStatus = status);
                              return;
                            }
                            if (status.isPermanentlyDenied) {
                              await openAppSettings();
                              return;
                            }
                          },
                          child: const Text('Scan image'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _cameraPermissionStatus = status;
  }

  Future<void> _onTap(TapUpDetails details) async {
    if (_cameraController == null) return;
    if (_cameraController!.value.isInitialized) {
      showFocusCircle = true;
      x = details.localPosition.dx;
      y = details.localPosition.dy;

      double fullWidth = MediaQuery.of(context).size.width;
      double cameraHeight = fullWidth * _cameraController!.value.aspectRatio;

      double xp = x / fullWidth;
      double yp = y / cameraHeight;

      Offset point = Offset(xp, yp);
      debugPrint("point : $point");

      // Manually focus
      if (point.dx < 0 || point.dx > 1 || point.dy < 0 || point.dy > 1) {
        log('point out of bounds');
        return;
      }
      await _cameraController!.setFocusPoint(point);

      // Manually set light exposure
      //controller.setExposurePoint(point);

      setState(() {
        Future.delayed(const Duration(milliseconds: 100)).whenComplete(() {
          setState(() {
            showFocusCircle = false;
          });
        });
      });
    }
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera.
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _takePhotoAndProcess() async {
    if (_cameraController == null) return;

    final navigator = Navigator.of(context);

    try {
      await _cameraController!.setFocusMode(FocusMode.locked);
      await _cameraController!.setExposureMode(ExposureMode.locked);
      final pictureFile = await _cameraController!.takePicture();
      await _cameraController!.setFocusMode(FocusMode.auto);
      await _cameraController!.setExposureMode(ExposureMode.auto);

      final file = File(pictureFile.path);
      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);
      var phones = Helpers.getPhonesFromRowText(recognizedText.text);

      if (phones.length > 5) {
        await navigator.push(
          MaterialPageRoute(
            builder: (BuildContext context) => ResultScreen(phones: phones),
          ),
        );
      } else {
        _showPhonesDialog(phones);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
  }

  void _showPhonesDialog(List<String> phones) {
    showDialog(
      context: context,
      builder: (context) {
        return ResultDialog(phones: phones);
      },
    );
  }
}
