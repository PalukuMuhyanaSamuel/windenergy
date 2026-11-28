import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:windenergy/features/data/services/db_service.dart';
import 'package:windenergy/features/data/services/firebase/models/pairing_code_firebase_model.dart';
import 'package:windenergy/features/data/services/firebase/models/turbine_firebase_model.dart';
import 'package:windenergy/features/domain/entities/pairing_code.dart';
import 'package:windenergy/features/domain/entities/position.dart';
import 'package:windenergy/features/domain/entities/profile.dart';
import 'package:windenergy/features/domain/entities/turbine.dart';
import 'package:windenergy/utils/exceptions.dart';
import 'package:windenergy/utils/result.dart';

import 'models/profile_firebase_model.dart';

class FirebaseService extends DbService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FirebaseService({
    required this.firestore,
    required this.auth,
  });

  bool _isInactive(Timestamp? lastSeenAt) {
    if (lastSeenAt == null) return true;
    return DateTime.now().difference(lastSeenAt.toDate()).inSeconds >= 30;
  }

  @override
  FutureResult<int> createTurbine({
    String userId = "",
    String serialNumber = "",
    String customName = "",
    Position position = const Position(),
  }) async {
    try {
      final counterRef = firestore.collection("counters").doc("turbines");
      final newDocRef = firestore.collection("turbines").doc();

      final newId = await firestore.runTransaction<int>((transaction) async {
        final counterSnap = await transaction.get(counterRef);
        final currentId = (counterSnap.data()?["last_id"] as int?) ?? 0;
        final nextId = currentId + 1;

        transaction.set(counterRef, {"last_id": nextId}, SetOptions(merge: true));
        transaction.set(newDocRef, {
          "id": nextId,
          "profile_id": userId,
          "serial_number": serialNumber,
          "custom_name": customName,
          "latitude": position.latitude,
          "longitude": position.longitude,
          "power_w": 0.0,
          "activated": false,
          "last_seen_at": FieldValue.serverTimestamp(),
          "created_at": FieldValue.serverTimestamp(),
        });

        return nextId;
      });

      return Success<int>(value: newId);
    } catch (e) {
      throw ServerException(reason: "an error occurred on the server");
    }
  }

  @override
  FutureResult<dynamic> deleteTurbine({int turbineId = 0}) async {
    try {
      final snap = await firestore
          .collection("turbines")
          .where("id", isEqualTo: turbineId)
          .limit(1)
          .get();

      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
      return Success();
    } catch (e) {
      throw ServerException(reason: "an error occurred on the server");
    }
  }

  @override
  FutureResult<int> readCount({String userId = ""}) async {
    try {
      final agg = await firestore
          .collection("turbines")
          .where("profile_id", isEqualTo: userId)
          .count()
          .get();
      return Success<int>(value: agg.count ?? 0);
    } catch (e) {
      throw ServerException(reason: "an error occurred on the server");
    }
  }

  @override
  FutureResult<PairingCode> readPairingCode({int turbineId = 0}) async {
    try {
      final snap = await firestore
          .collection("pairing_codes")
          .where("turbine_id", isEqualTo: turbineId)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        throw ServerException(reason: "pairing code not found");
      }
      return Success(
        value: PairingCodeFirebaseModel.fromMap(
          map: snap.docs.first.data(),
        ),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(reason: "an error occurred on the server");
    }
  }

  @override
  FutureResult<Profile> readProfile({String userId = ""}) async {
    try {
      final doc = await firestore.collection("profiles").doc(userId).get();
      if (!doc.exists || doc.data() == null) {
        throw ServerException(reason: "profile not found");
      }
      return Success(
        value: ProfileFirebaseModel.fromMap(
          map: doc.data()!,
          id: doc.id,
        ),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(reason: "an error occurred on the server");
    }
  }

  @override
  FutureResult<double> readTotalPowerW({String userId = ""}) async {
    try {
      final snap = await firestore
          .collection("turbines")
          .where("profile_id", isEqualTo: userId)
          .get();

      double totalPower = 0.0;
      for (final doc in snap.docs) {
        final data = doc.data();
        if (!_isInactive(data["last_seen_at"] as Timestamp?)) {
          totalPower += ((data["power_w"] as num?)?.toDouble() ?? 0.0);
        }
      }
      return Success(value: totalPower);
    } catch (e) {
      throw ServerException(reason: "an error occurred on the server");
    }
  }

  @override
  FutureResult<dynamic> readTurbineActivation() async {
    try {
      return Success();
    } catch (e) {
      throw ServerException(reason: "an error occurred on the server");
    }
  }

  @override
  FutureResult<List<Turbine>> readTurbines({String userId = ""}) async {
    try {
      final snap = await firestore
          .collection("turbines")
          .where("profile_id", isEqualTo: userId)
          .get();

      final ret = snap.docs.map((doc) {
        return TurbineFirebaseModel.fromMap(
          map: doc.data(),
          docId: doc.id,
        );
      }).toList();

      return Success(value: ret);
    } catch (e) {
      throw ServerException(reason: "an error occurred on the server");
    }
  }

  @override
  FutureResult<String> signIn({String email = "", String password = ""}) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        throw ServerException(reason: "invalid credentials");
      }
      return Success<String>(value: uid);
    } on FirebaseAuthException catch (e) {
      String reason = "an error occurred on the server";
      if (e.code == "invalid-credential" ||
          e.code == "wrong-password" ||
          e.code == "user-not-found") {
        reason = "invalid credentials";
      }
      throw ServerException(reason: reason);
    } catch (e) {
      throw ServerException(reason: "an error occurred on the server");
    }
  }

  @override
  FutureResult<dynamic> signOut() async {
      await auth.signOut();
      return Success();
  }

  @override
  FutureResult<String> signUp({
    String fullName = "",
    String email = "",
    String password = "",
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw ServerException(reason: "an error occurred on the server");
      }

      await firestore.collection("profiles").doc(user.uid).set({
        "full_name": fullName,
        "email": email,
        "created_at": FieldValue.serverTimestamp(),
      });

      return Success<String>(value: user.uid);
    } on FirebaseAuthException catch (e) {
      String reason = "an error occurred on the server";
      if (e.code == "email-already-in-use") {
        reason = "email address already exists in the system";
      }
      throw ServerException(reason: reason);
    } catch (e) {
      throw ServerException(reason: "an error occurred on the server");
    }
  }

  @override
  FutureResult<dynamic> updateTurbine({
    int turbineId = 0,
    String customName = "",
    Position position = const Position(),
  }) async {
    try {
      final snap = await firestore
          .collection("turbines")
          .where("id", isEqualTo: turbineId)
          .limit(1)
          .get();

      for (final doc in snap.docs) {
        await doc.reference.update({
          "custom_name": customName,
          "latitude": position.latitude,
          "longitude": position.longitude,
        });
      }
      return Success();
    } catch (e) {
      throw ServerException(reason: "an error occurred on the server");
    }
  }
}