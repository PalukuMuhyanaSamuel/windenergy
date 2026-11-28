import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:windenergy/features/domain/entities/pairing_code.dart';

class PairingCodeFirebaseModel {
  static PairingCode fromMap({required Map<String, dynamic> map}) {
    final codeValue = (map['code_hash'] as String?) ?? '';
    final rawStatus = (map['status'] as String?)?.toLowerCase();

    return PairingCode(
      turbineId: (map['turbine_id'] as int?) ?? (map['id'] as int?) ?? 0,
      codeHash: codeValue,
      createdAd: _parseDate(map['created_at']) ?? DateTime.now(),
      expiresAt: _parseDate(map['expires_at']) ?? DateTime.now(),
      status: rawStatus == 'valid' ? ParingStatus.valid : ParingStatus.invalid,
      validatedAt: _parseDate(map['validated_at']),
    );
  }

  static Map<String, dynamic> toMap({
    int? id,
    required int turbineId,
    required String codeHash,
    required String status,
    DateTime? expiresAt,
    DateTime? validatedAt,
  }) {
    return {
      if (id != null) 'id': id,
      'turbine_id': turbineId,
      'code_hash': codeHash,
      'status': status,
      if (expiresAt != null) 'expires_at': Timestamp.fromDate(expiresAt),
      if (validatedAt != null) 'validated_at': Timestamp.fromDate(validatedAt),
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}