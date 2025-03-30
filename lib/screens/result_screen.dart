import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/scan_result.dart';
import '../themes/app_theme.dart';

class ResultScreen extends StatelessWidget {
  final ScanResult? scanResult;

  const ResultScreen({Key? key, this.scanResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as ScanResult?;
    final result = scanResult ?? args;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No scan results available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareResults(context, result),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVerificationStatus(result),
            const SizedBox(height: 24),
            _buildMedicineImage(result),
            const SizedBox(height: 24),
            _buildMedicineDetails(result),
            const SizedBox(height: 24),
            _buildBlockchainDetails(result),
            const SizedBox(height: 24),
            if (!result.isAuthentic) _buildReportButton(context, result),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStatus(ScanResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result.isAuthentic
            ? AppTheme.successColor.withOpacity(0.2)
            : AppTheme.errorColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            result.isAuthentic ? Icons.verified : Icons.warning,
            color: result.isAuthentic ? AppTheme.successColor : AppTheme.errorColor,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.isAuthentic ? 'Authentic Medicine' : 'Potential Counterfeit',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.isAuthentic
                      ? 'This medicine has been verified as authentic'
                      : 'Warning: This medicine may be counterfeit',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                if (result.confidence > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineImage(ScanResult result) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: result.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: result.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            : const Center(
                child: Icon(Icons.medication, size: 60, color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildMedicineDetails(ScanResult result) {
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
            const Text(
              'Medicine Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Name', result.medicineName),
            _buildDetailRow('Manufacturer', result.manufacturer),
            if (result.batchNumber != null)
              _buildDetailRow('Batch Number', result.batchNumber!),
            if (result.expiryDate != null)
              _buildDetailRow('Expiry Date', result.expiryDate!),
            if (result.productionDate != null)
              _buildDetailRow('Production Date', result.productionDate!),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockchainDetails(ScanResult result) {
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
            const Text(
              'Blockchain Verification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Transaction ID', result.transactionId),
            const SizedBox(height: 8),
            const Text(
              'This medicine has been registered on the blockchain, ensuring its authenticity and traceability.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton(BuildContext context, ScanResult result) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.errorColor.withOpacity(0.1),
          foregroundColor: AppTheme.errorColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _reportCounterfeit(context, result),
        child: const Text('Report Counterfeit'),
      ),
    );
  }

  void _shareResults(BuildContext context, ScanResult result) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _reportCounterfeit(BuildContext context, ScanResult result) {
    // TODO: Implement counterfeit reporting
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Counterfeit reporting coming soon')),
    );
  }
}