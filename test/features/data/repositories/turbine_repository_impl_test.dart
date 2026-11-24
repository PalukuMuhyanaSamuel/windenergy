import 'package:flutter_test/flutter_test.dart';
import 'package:windenergy/features/data/repositories/turbine_repository_impl.dart';
import 'package:windenergy/features/data/services/db_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:windenergy/features/domain/entities/pairing_code.dart';
import 'package:windenergy/features/domain/entities/position.dart';
import 'package:windenergy/features/domain/entities/turbine.dart';
import 'package:windenergy/utils/exceptions.dart';
import 'package:windenergy/utils/result.dart';

class MockDbService extends Mock implements DbService {}

void main() {
  late MockDbService mockDbService;
  late TurbineRepositoryImpl turbineRepositoryImpl;

  setUp(() {
    mockDbService = MockDbService();
    turbineRepositoryImpl = TurbineRepositoryImpl(dbService: mockDbService);
  });

  group("createTurbine", () {
    test("should return Success", () async {
      final serialNumber = "12345";
      final customName = "test";
      final position = const Position(latitude: 30.5, longitude: 1.5);
      when(() => mockDbService.createTurbine(
        serialNumber: serialNumber,
        customName: customName,
        latitude: position.latitude,
        longitude: position.longitude,
      )).thenAnswer((_) async => Success<int>());
      final result = await turbineRepositoryImpl.createTurbine(
          serialNumber: serialNumber,
          customName: customName,
          position: position);
      expect(result, Success<int>());
    });

    test("Should return Error", () async {
      final serialNumber = "12345";
      final customName = "test";
      final position = const Position(latitude: 30.5, longitude: 1.5);
      when(() => mockDbService.createTurbine(
        serialNumber: serialNumber,
        customName: customName,
        latitude: position.latitude,
        longitude: position.longitude,
      )).thenThrow(ServerException());
      final result = await turbineRepositoryImpl.createTurbine(
          serialNumber: serialNumber,
          customName: customName,
          position: position);
      expect(result, Error<int>());
    });
  });

  group("DeleteTurbine", () {
    test("should return Success", () async {
      final turbineId = 1;
      when(() => mockDbService.deleteTurbine(turbineId: turbineId))
          .thenAnswer((_) async => Success());
      final result =
      await turbineRepositoryImpl.deleteTurbine(turbineId: turbineId);
      expect(result, Success());
    });

    test("Should return Error", () async {
      final turbineId = 1;
      when(() => mockDbService.deleteTurbine(turbineId: turbineId))
          .thenThrow(ServerException());
      final result =
      await turbineRepositoryImpl.deleteTurbine(turbineId: turbineId);
      expect(result, Error());
    });
  });

  group("ReadCount", () {
    test("should return Success", () async {
      when(() => mockDbService.readCount())
          .thenAnswer((_) async => Success<int>());
      final result = await turbineRepositoryImpl.readCount();
      expect(result, Success<int>());
    });

    test("Should return Error", () async {
      when(() => mockDbService.readCount()).thenThrow(ServerException());
      final result = await turbineRepositoryImpl.readCount();
      expect(result, Error<int>());
    });
  });

  group("ReadPairingCode", () {
    test("should return Success", () async {
      final turbineId = 1;
      when(() => mockDbService.readPairingCode(turbineId: turbineId))
          .thenAnswer((_) async => Success<PairingCode>());
      final result =
      await turbineRepositoryImpl.readPairingCode(turbineId: turbineId);
      expect(result, Success<PairingCode>());
    });

    test("Should return Error", () async {
      final turbineId = 1;
      when(() => mockDbService.readPairingCode(turbineId: turbineId))
          .thenThrow(ServerException());
      final result =
      await turbineRepositoryImpl.readPairingCode(turbineId: turbineId);
      expect(result, Error<PairingCode>());
    });
  });

  group("ReadTotalPowerW", () {
    test("should return Success", () async {
      when(() => mockDbService.readTotalPowerW())
          .thenAnswer((_) async => Success<double>());
      final result = await turbineRepositoryImpl.readTotalPowerW();
      expect(result, Success<double>());
    });

    test("Should return Error", () async {
      when(() => mockDbService.readTotalPowerW()).thenThrow(ServerException());
      final result = await turbineRepositoryImpl.readTotalPowerW();
      expect(result, Error<double>());
    });
  });

  group("ReadTurbineActivation", () {
    test("should return Success", () async {
      when(() => mockDbService.readTurbineActivation())
          .thenAnswer((_) async => Success());
      final result = await turbineRepositoryImpl.readTurbineActivation();
      expect(result, Success());
    });

    test("Should return Error", () async {
      when(() => mockDbService.readTurbineActivation())
          .thenThrow(ServerException());
      final result = await turbineRepositoryImpl.readTurbineActivation();
      expect(result, Error());
    });
  });

  group("ReadTurbines", () {
    test("should return Success", () async {
      when(() => mockDbService.readTurbines())
          .thenAnswer((_) async => Success<List<Turbine>>());
      final result = await turbineRepositoryImpl.readTurbines();
      expect(result, Success<List<Turbine>>());
    });

    test("Should return Error", () async {
      when(() => mockDbService.readTurbines()).thenThrow(ServerException());
      final result = await turbineRepositoryImpl.readTurbines();
      expect(result, Error<List<Turbine>>());
    });
  });

  group("UpdateTurbine", () {
    test("should return Success", () async {
      final turbineId = 1;
      final customName = "test";
      final position = const Position(latitude: 30.5, longitude: 1.5);
      when(() => mockDbService.updateTurbine(
        turbineId: turbineId,
        customName: customName,
        latitude: position.latitude,
        longitude: position.longitude,
      )).thenAnswer((_) async => Success());
      final result = await turbineRepositoryImpl.updateTurbine(
          turbineId: turbineId,
          customName: customName,
          position: position);
      expect(result, Success());
    });

    test("Should return Error", () async {
      final turbineId = 1;
      final customName = "test";
      final position = const Position(latitude: 30.5, longitude: 1.5);
      when(() => mockDbService.updateTurbine(
        turbineId: turbineId,
        customName: customName,
        latitude: position.latitude,
        longitude: position.longitude,
      )).thenThrow(ServerException());
      final result = await turbineRepositoryImpl.updateTurbine(
          turbineId: turbineId,
          customName: customName,
          position: position);
      expect(result, Error());
    });
  });
}