import "package:equatable/equatable.dart";

enum ParingStatus{valid, invalid}

class PairingCode extends Equatable{
  final int turbineId;
  final String codeHash;
  final ParingStatus status;
  final DateTime? expiresAt;
  final DateTime? createdAd;
  final DateTime? validatedAt;

  const PairingCode({
    this.turbineId=0,
    this.codeHash="",
    this.status = ParingStatus.invalid,
    this.expiresAt,
    this.createdAd,
    this.validatedAt,

});

  @override
  List<Object?> get props => [turbineId, codeHash, createdAd];
}