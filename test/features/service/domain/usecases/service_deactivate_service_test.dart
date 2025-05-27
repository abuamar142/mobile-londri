import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:londri/features/service/domain/repositories/service_repository.dart';
import 'package:londri/features/service/domain/usecases/service_deactivate_service.dart';
import 'package:londri/core/error/failure.dart';

// Mock ServiceRepository
class MockServiceRepository extends Mock implements ServiceRepository {}

void main() {
  late ServiceDeactivateService usecase;
  late MockServiceRepository mockServiceRepository;

  setUp(() {
    mockServiceRepository = MockServiceRepository();
    usecase = ServiceDeactivateService(mockServiceRepository);
  });

  const tServiceId = 'test-service-id';
  final tServerFailure = ServerFailure('Server error');

  group('ServiceDeactivateService', () {
    test('should call deactivateService on the repository and return Right(null) on success', () async {
      // Arrange
      when(mockServiceRepository.deactivateService(any)).thenAnswer((_) async => Right(null));

      // Act
      final result = await usecase(tServiceId);

      // Assert
      expect(result, Right(null));
      verify(mockServiceRepository.deactivateService(tServiceId));
      verifyNoMoreInteractions(mockServiceRepository);
    });

    test('should call deactivateService on the repository and return Left(Failure) on failure', () async {
      // Arrange
      when(mockServiceRepository.deactivateService(any)).thenAnswer((_) async => Left(tServerFailure));

      // Act
      final result = await usecase(tServiceId);

      // Assert
      expect(result, Left(tServerFailure));
      verify(mockServiceRepository.deactivateService(tServiceId));
      verifyNoMoreInteractions(mockServiceRepository);
    });
  });
}
