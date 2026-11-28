import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:windenergy/features/domain/entities/profile.dart';

class ProfileFirebaseModel {
  static Profile fromMap({
    required Map<String, dynamic> map,
    required String id,
  }) {
    return Profile(
      id: id,
      fullName: (map['full_name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
    );
  }

  static Map<String, dynamic> toMap({
    required String fullName,
    required String email,
    bool includeCreatedAt = true,
  }) {
    return {
      'full_name': fullName,
      'email': email,
      if (includeCreatedAt) 'created_at': FieldValue.serverTimestamp(),
    };
  }
}