import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:londri/features/service/domain/entities/service.dart';
import 'package:londri/features/service/domain/repositories/service_repository.dart';
import 'package:londri/features/service/domain/usecases/service_get_active_services.dart';
import 'package:londri/core/error/failure.dart';

// Mock ServiceRepository
class MockServiceRepository extends Mock implements ServiceRepository {}

void main() {
  late ServiceGetActiveServices usecase;
  late MockServiceRepository mockServiceRepository;

  setUp(() {
    mockServiceRepository = MockServiceRepository();
    usecase = ServiceGetActiveServices(mockServiceRepository);
  });

  // Sample Service list for testing
  final tService1 = Service(
    id: 1,
    name: 'Active Service 1',
    price: 100,
    description: 'Description 1',
    isActive: true,
    createdAt: DateTime.now(),
  );
  final tService2 = Service(
    id: 2,
    name: 'Active Service 2',
    price: 200,
    description: 'Description 2',
    isActive: true,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  );
  final tActiveServicesList = [tService1, tService2];
  final tEmptyServicesList = <Service>[];

  // Sample Failure for testing
  final tServerFailure = ServerFailure('Server error');

  group('ServiceGetActiveServices', () {
    test('should get list of active services from the repository', () async {
      // Arrange
      when(mockServiceRepository.getActiveServices()).thenAnswer((_) async => Right(tActiveServicesList));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(tActiveServicesList));
      verify(mockServiceRepository.getActiveServices());
      verifyNoMoreInteractions(mockServiceRepository);
    });

    test('should get empty list from the repository if no active services exist', () async {
      // Arrange
      when(mockServiceRepository.getActiveServices()).thenAnswer((_) async => Right(tEmptyServicesList));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(tEmptyServicesList));
      verify(mockServiceRepository.getActiveServices());
      verifyNoMoreInteractions(mockServiceRepository);
    });

    test('should return Failure when the call to repository is unsuccessful', () async {
      // Arrange
      when(mockServiceRepository.getActiveServices()).thenAnswer((_) async => Left(tServerFailure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Left(tServerFailure));
      verify(mockServiceRepository.getActiveServices());
      verifyNoMoreInteractions(mockServiceRepository);
    });
  });
}
