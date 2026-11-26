import 'package:windenergy/features/domain/entities/pairing_code.dart';

class PairingCodeSupabaseModel extends PairingCode{
  const PairingCodeSupabaseModel({
    super.turbineId,
    super.codeHash,
    super.createdAd,
    super.expiresAt,
    super.status,
    super.validatedAt
  });

  factory PairingCodeSupabaseModel.fromMap({required Map<String, dynamic> map}){
    final pairingCode = PairingCodeSupabaseModel(
      turbineId: map["turbine_id"],
      codeHash: map["code_hash"],
      createdAd: DateTime.parse(map["created_at"]),
      expiresAt: DateTime.parse(map["expires_at"]),
      status: map["status"] == "valid"? ParingStatus.valid: ParingStatus.invalid,
      validatedAt: DateTime.parse(map["validated_at"])
    );
    return pairingCode;
  }
}