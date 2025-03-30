import 'package:flutter/foundation.dart';

class ScanResult {
  final String transactionId;
  final bool isAuthentic;
  final double confidence;
  final String medicineName;
  final String manufacturer;
  final String? batchNumber;
  final String? expiryDate;
  final String? productionDate;
  final String? imageUrl;
  final VerificationMethod verificationMethod;

  ScanResult({
    required this.transactionId,
    required this.isAuthentic,
    required this.confidence,
    required this.medicineName,
    required this.manufacturer,
    this.batchNumber,
    this.expiryDate,
    this.productionDate,
    this.imageUrl,
    required this.verificationMethod,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      transactionId: json['transaction_id'],
      isAuthentic: json['is_authentic'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
      medicineName: json['medicine_name'],
      manufacturer: json['manufacturer'],
      batchNumber: json['batch_number'],
      expiryDate: json['expiry_date'],
      productionDate: json['production_date'],
      imageUrl: json['image_url'],
      verificationMethod: VerificationMethod.values.firstWhere(
        (e) => describeEnum(e) == json['verification_method'],
        orElse: () => VerificationMethod.ai,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'is_authentic': isAuthentic,
      'confidence': confidence,
      'medicine_name': medicineName,
      'manufacturer': manufacturer,
      'batch_number': batchNumber,
      'expiry_date': expiryDate,
      'production_date': productionDate,
      'image_url': imageUrl,
      'verification_method': describeEnum(verificationMethod),
    };
  }
}

class NFTData {
  final String transactionHash;
  final String blockNumber;
  final String timestamp;
  final String ownerAddress;
  final String manufacturerAddress;
  final List<String> previousOwners;

  NFTData({
    required this.transactionHash,
    required this.blockNumber,
    required this.timestamp,
    required this.ownerAddress,
    required this.manufacturerAddress,
    required this.previousOwners,
  });

  factory NFTData.fromJson(Map<String, dynamic> json) {
    return NFTData(
      transactionHash: json['transaction_hash'],
      blockNumber: json['block_number'],
      timestamp: json['timestamp'],
      ownerAddress: json['owner_address'],
      manufacturerAddress: json['manufacturer_address'],
      previousOwners: List<String>.from(json['previous_owners']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_hash': transactionHash,
      'block_number': blockNumber,
      'timestamp': timestamp,
      'owner_address': ownerAddress,
      'manufacturer_address': manufacturerAddress,
      'previous_owners': previousOwners,
    };
  }
}

enum VerificationMethod {
  ai,
  qr,
  nfc,
  manual,
}