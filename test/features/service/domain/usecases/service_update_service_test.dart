import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:londri/features/service/domain/entities/service.dart';
import 'package:londri/features/service/domain/repositories/service_repository.dart';
import 'package:londri/features/service/domain/usecases/service_update_service.dart';
import 'package:londri/core/error/failure.dart';

// Mock ServiceRepository
class MockServiceRepository extends Mock implements ServiceRepository {}

void main() {
  late ServiceUpdateService usecase;
  late MockServiceRepository mockServiceRepository;

  setUp(() {
    mockServiceRepository = MockServiceRepository();
    usecase = ServiceUpdateService(mockServiceRepository);
  });

  // Sample Service entity for testing
  final tService = Service(
    id: 1, // Assuming id is part of the service for update identification
    name: 'Updated Test Service',
    price: 150,
    description: 'Updated Test Description',
    isActive: true,
    createdAt: DateTime.now().subtract(const Duration(days: 5)), // Should exist
    // Ensure all fields required by Service entity are present
  );

  // Sample Failure for testing
  final tServerFailure = ServerFailure('Server error');

  group('ServiceUpdateService', () {
    test('should call updateService on the repository and return Right(null) on success', () async {
      // Arrange
      when(mockServiceRepository.updateService(any)).thenAnswer((_) async => Right(null));

      // Act
      final result = await usecase(tService);

      // Assert
      expect(result, Right(null));
      verify(mockServiceRepository.updateService(tService));
      verifyNoMoreInteractions(mockServiceRepository);
    });

    test('should call updateService on the repository and return Left(Failure) on failure', () async {
      // Arrange
      when(mockServiceRepository.updateService(any)).thenAnswer((_) async => Left(tServerFailure));

      // Act
      final result = await usecase(tService);

      // Assert
      expect(result, Left(tServerFailure));
      verify(mockServiceRepository.updateService(tService));
      verifyNoMoreInteractions(mockServiceRepository);
    });
  });
}
