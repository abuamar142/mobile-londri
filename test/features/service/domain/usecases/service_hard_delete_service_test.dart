import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:londri/features/service/domain/repositories/service_repository.dart';
import 'package:londri/features/service/domain/usecases/service_hard_delete_service.dart';
import 'package:londri/core/error/failure.dart';

// Mock ServiceRepository
class MockServiceRepository extends Mock implements ServiceRepository {}

void main() {
  late ServiceHardDeleteService usecase;
  late MockServiceRepository mockServiceRepository;

  setUp(() {
    mockServiceRepository = MockServiceRepository();
    usecase = ServiceHardDeleteService(mockServiceRepository);
  });

  const tServiceId = 'test-id';
  final tServerFailure = ServerFailure('Server error');

  group('ServiceHardDeleteService', () {
    test('should call hardDeleteService on the repository and return Right(null) on success', () async {
      // Arrange
      when(mockServiceRepository.hardDeleteService(any)).thenAnswer((_) async => Right(null));

      // Act
      final result = await usecase(tServiceId);

      // Assert
      expect(result, Right(null));
      verify(mockServiceRepository.hardDeleteService(tServiceId));
      verifyNoMoreInteractions(mockServiceRepository);
    });

    test('should call hardDeleteService on the repository and return Left(Failure) on failure', () async {
      // Arrange
      when(mockServiceRepository.hardDeleteService(any)).thenAnswer((_) async => Left(tServerFailure));

      // Act
      final result = await usecase(tServiceId);

      // Assert
      expect(result, Left(tServerFailure));
      verify(mockServiceRepository.hardDeleteService(tServiceId));
      verifyNoMoreInteractions(mockServiceRepository);
    });
  });
}
