import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'screens/scan_screen.dart';
import 'screens/result_screen.dart';
import 'themes/app_theme.dart';
import 'services/api_service.dart';
import 'utils/permission_handler.dart';

const String API_URL = 'https://medichain-api.example.com';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiService(API_URL)),
      ],
      child: MediChainApp(cameras: cameras),
    ),
  );
}

class MediChainApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MediChainApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediChain',
      theme: AppTheme.lightTheme,
      home: HomeScreen(cameras: cameras),
      routes: {
        '/scan': (context) => ScanScreen(cameras: cameras),
        '/result': (context) => const ResultScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String scanMode = 'ai';
  bool isLoading = false;
  ScanResult? scanResult;
  NFTData? nftData;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingScreen();
    }

    if (scanResult != null) {
      return _buildResultScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/medichain-logo.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 10),
            Text(
              'MediChain',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
      body: _buildHomeContent(),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: Text(
            'MediChain - Fighting Counterfeit Medicines',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Processing...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Verify your medicine's authenticity with AI and blockchain technology",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeButton('AI Scan', Icons.camera_alt, 'ai'),
              const SizedBox(width: 20),
              _buildModeButton('QR Scan', Icons.qr_code_scanner, 'qr'),
            ],
          ),
          const SizedBox(height: 40),
          _buildHowItWorksCard(),
        ],
      ),
    );
  }

  Widget _buildModeButton(String text, IconData icon, String mode) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: scanMode == mode
            ? Theme.of(context).primaryColor
            : Colors.grey.shade200,
      ),
      onPressed: () {
        setState(() {
          scanMode = mode;
        });
        _startScanning();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: scanMode == mode ? Colors.white : Colors.grey.shade800,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: scanMode == mode ? Colors.white : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How It Works',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            _buildStep('1. Scan medicine packaging', Icons.camera),
            _buildStep('2. AI verifies authenticity', Icons.verified),
            _buildStep('3. Check blockchain record', Icons.link),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    // Will be implemented in result_screen.dart
    return const ResultScreen();
  }

  Future<void> _startScanning() async {
    final hasPermission = await PermissionUtils.requestCameraPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required for scanning'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.pushNamed(context, '/scan');
  }
}