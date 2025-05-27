import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:londri/features/service/domain/entities/service.dart';
import 'package:londri/features/service/domain/repositories/service_repository.dart';
import 'package:londri/features/service/domain/usecases/service_get_service_by_id.dart';
import 'package:londri/core/error/failure.dart';

// Mock ServiceRepository
class MockServiceRepository extends Mock implements ServiceRepository {}

void main() {
  late ServiceGetServiceById usecase;
  late MockServiceRepository mockServiceRepository;

  setUp(() {
    mockServiceRepository = MockServiceRepository();
    usecase = ServiceGetServiceById(mockServiceRepository);
  });

  const tServiceId = 'test-id'; // Example service ID
  final tService = Service(
    id: 1, // Assuming the entity's ID is int, matching previous examples
    name: 'Test Service',
    price: 150,
    description: 'Detailed description of the test service.',
    isActive: true,
    createdAt: DateTime.now(),
  );

  final tServerFailure = ServerFailure('Service not found');
  final tGenericServerFailure = ServerFailure('Server error');

  group('ServiceGetServiceById', () {
    test('should get service from the repository when service is found', () async {
      // Arrange
      when(mockServiceRepository.getServiceById(any)).thenAnswer((_) async => Right(tService));

      // Act
      final result = await usecase(tServiceId);

      // Assert
      expect(result, Right(tService));
      verify(mockServiceRepository.getServiceById(tServiceId));
      verifyNoMoreInteractions(mockServiceRepository);
    });

    test('should return Failure when the service is not found', () async {
      // Arrange
      when(mockServiceRepository.getServiceById(any)).thenAnswer((_) async => Left(tServerFailure));

      // Act
      final result = await usecase(tServiceId);

      // Assert
      expect(result, Left(tServerFailure));
      verify(mockServiceRepository.getServiceById(tServiceId));
      verifyNoMoreInteractions(mockServiceRepository);
    });

    test('should return Failure on other server errors', () async {
      // Arrange
      when(mockServiceRepository.getServiceById(any)).thenAnswer((_) async => Left(tGenericServerFailure));

      // Act
      final result = await usecase(tServiceId);

      // Assert
      expect(result, Left(tGenericServerFailure));
      verify(mockServiceRepository.getServiceById(tServiceId));
      verifyNoMoreInteractions(mockServiceRepository);
    });
  });
}
