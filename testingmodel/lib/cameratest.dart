import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class Cameratest extends StatefulWidget {
  const Cameratest({super.key});

  @override
  State<Cameratest> createState() => _CameratestState();
}

class _CameratestState extends State<Cameratest> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  String? prediction = "No prediction yet"; // To display model predictions

  @override
  void initState() {
    super.initState();
    _setUpCameraController();
    _loadModel(); // Load the TFLite model
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Your Plant"),
      ),
      body: buildUI(),
    );
  }

  Widget buildUI() {
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SafeArea(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.38,
              width: MediaQuery.sizeOf(context).width * 0.80,
              child: CameraPreview(cameraController!),
            ),
            Text(
              prediction ?? "No Prediction",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: _runModelOnFrame,
              child: Text("Analyze Frame"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setUpCameraController() async {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      setState(() {
        cameras = _cameras;
        cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.high,
        );
      });
      cameraController?.initialize().then((_) {
        setState(() {});
      });
    }
  }

  Future<void> _loadModel() async {
    String? result = await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
    print("Model loaded: $result");
  }

  Future<void> _runModelOnFrame() async {
    if (cameraController != null && cameraController!.value.isInitialized) {
      try {
        final image = await cameraController!.takePicture();
        final predictions = await Tflite.runModelOnImage(
          path: image.path,
          numResults: 5, // Adjust based on your needs
          threshold: 0.5,
          imageMean: 127.5,
          imageStd: 127.5,
        );
        setState(() {
          prediction = predictions?.isNotEmpty == true
              ? predictions!.map((p) => "${p['label']} (${(p['confidence'] * 100).toStringAsFixed(2)}%)").join("\n")
              : "No prediction found";
        });
      } catch (e) {
        print("Error running model: $e");
      }
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    Tflite.close(); // Release TFLite resources
    super.dispose();
  }
}

