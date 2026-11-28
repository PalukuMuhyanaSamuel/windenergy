import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:windenergy/features/data/services/firebase/models/position_firebase_model.dart';
import 'package:windenergy/features/domain/entities/turbine.dart';

class TurbineFirebaseModel {
  static Turbine fromMap({
    required Map<String, dynamic> map,
    String? docId,
  }) {
    final lastSeenTimestamp = map['last_seen_at'] as Timestamp?;
    final createdAtTimestamp = map['created_at'] as Timestamp?;
    final isInactiveByTime = isInactive(lastSeenTimestamp);

    final rawStatus = (map['status'] as String?)?.toUpperCase();
    final TurbineStatus status;
    if (rawStatus == 'INACTIVE') {
      status = TurbineStatus.inactive;
    } else if (rawStatus == 'ACTIVE') {
      status = TurbineStatus.active;
    } else {
      status = isInactiveByTime ? TurbineStatus.inactive : TurbineStatus.active;
    }

    return Turbine(
      id: (map['id'] as int?) ?? 0,
      serialNumber: (map['serial_number'] as String?) ?? '',
      customName: (map['custom_name'] as String?) ?? '',
      status: status,
      position: PositionFirebaseModel.fromMap(map: map),
      createAt: createdAtTimestamp?.toDate(),
    );
  }

  static bool isInactive(Timestamp? lastSeenAt) {
    if (lastSeenAt == null) return true;
    return DateTime.now().difference(lastSeenAt.toDate()).inSeconds >= 30;
  }
}