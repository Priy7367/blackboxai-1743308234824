import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/scan_result.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<ScanResult> verifyMedicine({
    required String imagePath,
    required String scanMode,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/verify');
      final request = http.MultipartRequest('POST', uri)
        ..fields['mode'] = scanMode
        ..files.add(await http.MultipartFile.fromPath('image', imagePath));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return ScanResult.fromJson(jsonDecode(responseBody));
      } else {
        throw Exception('Verification failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API Error: $e');
      rethrow;
    }
  }

  Future<NFTData> fetchBlockchainDetails(String transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/blockchain/$transactionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return NFTData.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch blockchain details');
      }
    } catch (e) {
      debugPrint('Blockchain API Error: $e');
      rethrow;
    }
  }

  Future<bool> reportCounterfeit(String transactionId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/report'),
        body: jsonEncode({'transaction_id': transactionId}),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Report API Error: $e');
      return false;
    }
  }
}