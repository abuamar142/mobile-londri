import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:londri/features/service/domain/entities/service.dart';
import 'package:londri/features/service/domain/repositories/service_repository.dart';
import 'package:londri/features/service/domain/usecases/service_get_services.dart';
import 'package:londri/core/error/failure.dart';

// Mock ServiceRepository
class MockServiceRepository extends Mock implements ServiceRepository {}

void main() {
  late ServiceGetServices usecase;
  late MockServiceRepository mockServiceRepository;

  setUp(() {
    mockServiceRepository = MockServiceRepository();
    usecase = ServiceGetServices(mockServiceRepository);
  });

  // Sample Service list for testing
  final tService1 = Service(
    id: 1,
    name: 'Test Service 1',
    price: 100,
    description: 'Description 1',
    isActive: true,
    createdAt: DateTime.now(),
  );
  final tService2 = Service(
    id: 2,
    name: 'Test Service 2',
    price: 200,
    description: 'Description 2',
    isActive: false,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  );
  final tServicesList = [tService1, tService2];
  final tEmptyServicesList = <Service>[];

  // Sample Failure for testing
  final tServerFailure = ServerFailure('Server error');

  group('ServiceGetServices', () {
    test('should get list of services from the repository', () async {
      // Arrange
      when(mockServiceRepository.getServices()).thenAnswer((_) async => Right(tServicesList));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(tServicesList));
      verify(mockServiceRepository.getServices());
      verifyNoMoreInteractions(mockServiceRepository);
    });

    test('should get empty list of services from the repository if no services exist', () async {
      // Arrange
      when(mockServiceRepository.getServices()).thenAnswer((_) async => Right(tEmptyServicesList));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(tEmptyServicesList));
      verify(mockServiceRepository.getServices());
      verifyNoMoreInteractions(mockServiceRepository);
    });

    test('should return Failure when the call to repository is unsuccessful', () async {
      // Arrange
      when(mockServiceRepository.getServices()).thenAnswer((_) async => Left(tServerFailure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Left(tServerFailure));
      verify(mockServiceRepository.getServices());
      verifyNoMoreInteractions(mockServiceRepository);
    });
  });
}
