import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:londri/features/service/domain/repositories/service_repository.dart';
import 'package:londri/features/service/domain/usecases/service_activate_service.dart';
import 'package:londri/core/error/failure.dart';

// Mock ServiceRepository
class MockServiceRepository extends Mock implements ServiceRepository {}

void main() {
  late ServiceActivateService usecase;
  late MockServiceRepository mockServiceRepository;

  setUp(() {
    mockServiceRepository = MockServiceRepository();
    usecase = ServiceActivateService(mockServiceRepository);
  });

  const tServiceId = 'test-service-id'; // Using String as per common practice for IDs from Supabase/backend
  final tServerFailure = ServerFailure('Server error');

  group('ServiceActivateService', () {
    test('should call activateService on the repository and return Right(null) on success', () async {
      // Arrange
      when(mockServiceRepository.activateService(any)).thenAnswer((_) async => Right(null));

      // Act
      final result = await usecase(tServiceId);

      // Assert
      expect(result, Right(null));
      verify(mockServiceRepository.activateService(tServiceId));
      verifyNoMoreInteractions(mockServiceRepository);
    });

    test('should call activateService on the repository and return Left(Failure) on failure', () async {
      // Arrange
      when(mockServiceRepository.activateService(any)).thenAnswer((_) async => Left(tServerFailure));

      // Act
      final result = await usecase(tServiceId);

      // Assert
      expect(result, Left(tServerFailure));
      verify(mockServiceRepository.activateService(tServiceId));
      verifyNoMoreInteractions(mockServiceRepository);
    });
  });
}
