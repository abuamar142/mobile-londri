import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:londri/features/service/domain/entities/service.dart';
import 'package:londri/features/service/domain/repositories/service_repository.dart';
import 'package:londri/features/service/domain/usecases/service_create_service.dart';
import 'package:londri/core/error/failure.dart';

// Mock ServiceRepository
class MockServiceRepository extends Mock implements ServiceRepository {}

void main() {
  late ServiceCreateService usecase;
  late MockServiceRepository mockServiceRepository;

  setUp(() {
    mockServiceRepository = MockServiceRepository();
    usecase = ServiceCreateService(mockServiceRepository);
  });

  // Sample Service entity for testing
  final tService = Service(
    id: 1,
    name: 'Test Service',
    price: 100,
    description: 'Test Description',
    isActive: true,
    createdAt: DateTime.now(),
  );

  // Sample Failure for testing
  final tServerFailure = ServerFailure('Server error');

  group('ServiceCreateService', () {
    test('should call createService on the repository and return Right(null) on success', () async {
      // Arrange
      when(mockServiceRepository.createService(any)).thenAnswer((_) async => Right(null));

      // Act
      final result = await usecase(tService);

      // Assert
      expect(result, Right(null));
      verify(mockServiceRepository.createService(tService));
      verifyNoMoreInteractions(mockServiceRepository);
    });

    test('should call createService on the repository and return Left(Failure) on failure', () async {
      // Arrange
      when(mockServiceRepository.createService(any)).thenAnswer((_) async => Left(tServerFailure));

      // Act
      final result = await usecase(tService);

      // Assert
      expect(result, Left(tServerFailure));
      verify(mockServiceRepository.createService(tService));
      verifyNoMoreInteractions(mockServiceRepository);
    });
  });
}
