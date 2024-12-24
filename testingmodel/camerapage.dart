// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:tflite/tflite.dart';

// class CameraPage extends StatefulWidget {
//   const CameraPage({super.key});

//   @override
//   State<CameraPage> createState() => _CameraPageState();
// }

// class _CameraPageState extends State<CameraPage> {
//   CameraImage? cameraImage;
//   CameraController? cameraController;
//   String output = 'No Predictions Yet';
//   List<CameraDescription>? cameras;

//   @override
//   void initState() {
//     super.initState();
//     initializeCamera();
//     loadModel();
//   }

//   /// Initializes the camera and starts the image stream.
//   Future<void> initializeCamera() async {
//     try {
//       cameras = await availableCameras();

//       if (cameras != null && cameras!.isNotEmpty) {
//         cameraController = CameraController(
//           cameras![0],
//           ResolutionPreset.medium,
//         );

//         await cameraController!.initialize();

//         if (mounted) {
//           setState(() {
//             cameraController!.startImageStream((imageStream) {
//               cameraImage = imageStream;
//               runModel();
//             });
//           });
//         }
//       } else {
//         debugPrint("No cameras found");
//       }
//     } catch (e) {
//       debugPrint("Error initializing camera: $e");
//     }
//   }

//   /// Runs the TensorFlow Lite model on each frame from the camera.
//   Future<void> runModel() async {
//     if (cameraImage != null) {
//       try {
//         var predictions = await Tflite.runModelOnFrame(
//           bytesList: cameraImage!.planes.map((plane) => plane.bytes).toList(),
//           imageHeight: cameraImage!.height,
//           imageWidth: cameraImage!.width,
//           imageMean: 127.5,
//           imageStd: 127.5,
//           rotation: 90,
//           numResults: 2,
//           threshold: 0.1,
//           asynch: true,
//         );

//         if (predictions != null && predictions.isNotEmpty) {
//           setState(() {
//             output = predictions.map((e) => e['label']).join(', ');
//           });
//         } else {
//           setState(() {
//             output = "No Predictions Found";
//           });
//         }
//       } catch (e) {
//         debugPrint("Error running model: $e");
//       }
//     }
//   }

//   /// Loads the TensorFlow Lite model.
//   Future<void> loadModel() async {
//     try {
//       await Tflite.loadModel(
//         model: "assets/model_unquant.tflite",
//         labels: "assets/labels.txt",
//       );
//     } catch (e) {
//       debugPrint("Error loading model: $e");
//     }
//   }

//   /// Disposes the camera controller and closes the TFLite resources.
//   @override
//   void dispose() {
//     cameraController?.dispose();
//     Tflite.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         title: const Text(
//           "Test Your Plant",
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.7,
//               width: MediaQuery.of(context).size.width,
//               child: cameraController == null ||
//                       !cameraController!.value.isInitialized
//                   ? const Center(
//                       child: Text(
//                         "Loading Camera...",
//                         style: TextStyle(fontSize: 18),
//                       ),
//                     )
//                   : AspectRatio(
//                       aspectRatio: cameraController!.value.aspectRatio,
//                       child: CameraPreview(cameraController!),
//                     ),
//             ),
//           ),
//           Text(
//             output,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 20,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }