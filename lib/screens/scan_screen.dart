import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/scan_result.dart';

class ScanScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const ScanScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late MobileScannerController cameraController;
  bool isFlashOn = false;
  bool isProcessing = false;
  String currentMode = 'ai';

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      torchEnabled: isFlashOn,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Medicine'),
        actions: [
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() {
                isFlashOn = !isFlashOn;
                cameraController.toggleTorch();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: () {
              cameraController.switchCamera();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (currentMode == 'qr')
            MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                if (isProcessing) return;
                _processBarcode(capture.barcodes.first.rawValue ?? '');
              },
            )
          else
            CameraPreview(cameraController),
          _buildModeToggle(),
          if (isProcessing) _buildProcessingOverlay(),
        ],
      ),
      floatingActionButton: currentMode == 'ai'
          ? FloatingActionButton(
              onPressed: _captureImage,
              child: const Icon(Icons.camera),
            )
          : null,
    );
  }

  Widget _buildModeToggle() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModeButton('AI Scan', 'ai'),
              const SizedBox(width: 10),
              _buildModeButton('QR Scan', 'qr'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String text, String mode) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: currentMode == mode ? Colors.white : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          currentMode = mode;
        });
      },
      child: Text(text),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Processing...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImage() async {
    if (isProcessing) return;
    setState(() => isProcessing = true);

    try {
      final image = await cameraController.takePicture();
      final result = await Provider.of<ApiService>(context, listen: false)
          .verifyMedicine(imagePath: image.path, scanMode: currentMode);
      
      Navigator.pushReplacementNamed(
        context,
        '/result',
        arguments: result,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  Future<void> _processBarcode(String barcode) async {
    if (isProcessing) return;
    setState(() => isProcessing = true);

    try {
      final result = await Provider.of<ApiService>(context, listen: false)
          .verifyMedicine(imagePath: barcode, scanMode: currentMode);
      
      Navigator.pushReplacementNamed(
        context,
        '/result',
        arguments: result,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }
}