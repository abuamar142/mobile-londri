import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:londri/core/error/exceptions.dart';
import 'package:londri/core/error/failure.dart';
import 'package:londri/features/service/data/datasources/service_remote_datasource.dart';
import 'package:londri/features/service/data/models/service_model.dart';
import 'package:londri/features/service/data/repositories/service_repository_implementation.dart';
import 'package:londri/features/service/domain/entities/service.dart'; // Required for tServiceInput

// Mock ServiceRemoteDatasource
class MockServiceRemoteDatasource extends Mock implements ServiceRemoteDatasource {}

void main() {
  late ServiceRepositoryImplementation repository;
  late MockServiceRemoteDatasource mockRemoteDatasource;

  setUp(() {
    mockRemoteDatasource = MockServiceRemoteDatasource();
    repository = ServiceRepositoryImplementation(remoteDatasource: mockRemoteDatasource);
  });

  // Sample data
  const tServiceId = 'test-service-id';
  final tServiceModel = ServiceModel(
    id: 1,
    name: 'Test Service',
    price: 100,
    description: 'Test Description',
    // isActive is derived in ServiceModel constructor from deletedAt
    createdAt: DateTime.parse("2023-01-01T10:00:00.000Z"),
    updatedAt: DateTime.parse("2023-01-01T12:00:00.000Z"),
  );
  final List<ServiceModel> tServiceModelList = [tServiceModel];
  final List<ServiceModel> tEmptyServiceModelList = [];

  final tServerException = ServerException('Something went wrong');
  // Match the failure creation in the repository
  final tRepositoryFailure = Failure(message: tServerException.message);


  group('ServiceRepositoryImplementation', () {
    group('createService', () {
      // Use a Service entity for input, as per repository method signature
      final tServiceInput = Service(
        name: 'New Service',
        description: 'New Desc',
        price: 50,
      );

      test('should call createService on datasource with correctly constructed ServiceModel and return Right(null)', () async {
        // Arrange
        when(mockRemoteDatasource.createService(any)).thenAnswer((_) async => Future.value());
        // Act
        final result = await repository.createService(tServiceInput);
        // Assert
        expect(result, Right(null));
        verify(mockRemoteDatasource.createService(argThat(isA<ServiceModel>()
            .having((m) => m.name, 'name', tServiceInput.name)
            .having((m) => m.description, 'description', tServiceInput.description)
            .having((m) => m.price, 'price', tServiceInput.price)
            // createdAt and updatedAt are set by the repository, so we check for their presence
            .having((m) => m.createdAt, 'createdAt', isNotNull)
            .having((m) => m.updatedAt, 'updatedAt', isNotNull)
            )));
        verifyNoMoreInteractions(mockRemoteDatasource);
      });

      test('should return Left(Failure) when remote datasource throws ServerException', () async {
        // Arrange
        when(mockRemoteDatasource.createService(any)).thenThrow(tServerException);
        // Act
        final result = await repository.createService(tServiceInput);
        // Assert
        expect(result, Left(tRepositoryFailure));
        verify(mockRemoteDatasource.createService(argThat(isA<ServiceModel>())));
        verifyNoMoreInteractions(mockRemoteDatasource);
      });
    });

    group('getServices (uses readServices from datasource)', () {
      test('should return Right(List<Service>) when remote datasource is successful', () async {
        // Arrange
        when(mockRemoteDatasource.readServices()).thenAnswer((_) async => tServiceModelList);
        // Act
        final result = await repository.getServices();
        // Assert
        expect(result, Right(tServiceModelList)); 
        verify(mockRemoteDatasource.readServices());
        verifyNoMoreInteractions(mockRemoteDatasource);
      });

      test('should return Right(empty List<Service>) when remote datasource returns empty list', () async {
        // Arrange
        when(mockRemoteDatasource.readServices()).thenAnswer((_) async => tEmptyServiceModelList);
        // Act
        final result = await repository.getServices();
        // Assert
        expect(result, Right(tEmptyServiceModelList));
        verify(mockRemoteDatasource.readServices());
        verifyNoMoreInteractions(mockRemoteDatasource);
      });

      test('should return Left(Failure) when remote datasource throws ServerException', () async {
        // Arrange
        when(mockRemoteDatasource.readServices()).thenThrow(tServerException);
        // Act
        final result = await repository.getServices();
        // Assert
        expect(result, Left(tRepositoryFailure));
        verify(mockRemoteDatasource.readServices());
        verifyNoMoreInteractions(mockRemoteDatasource);
      });
    });

    group('getServiceById (uses readServiceById from datasource)', () {
      test('should return Right(Service) when remote datasource is successful', () async {
        // Arrange
        when(mockRemoteDatasource.readServiceById(any)).thenAnswer((_) async => tServiceModel);
        // Act
        final result = await repository.getServiceById(tServiceId);
        // Assert
        expect(result, Right(tServiceModel)); 
        verify(mockRemoteDatasource.readServiceById(tServiceId));
        verifyNoMoreInteractions(mockRemoteDatasource);
      });

      test('should return Left(Failure) when remote datasource throws ServerException', () async {
        // Arrange
        when(mockRemoteDatasource.readServiceById(any)).thenThrow(tServerException);
        // Act
        final result = await repository.getServiceById(tServiceId);
        // Assert
        expect(result, Left(tRepositoryFailure));
        verify(mockRemoteDatasource.readServiceById(tServiceId));
        verifyNoMoreInteractions(mockRemoteDatasource);
      });
    });

    group('activateService', () {
      test('should return Right(null) when remote datasource is successful', () async {
        // Arrange
        when(mockRemoteDatasource.activateService(any)).thenAnswer((_) async => Future.value());
        // Act
        final result = await repository.activateService(tServiceId);
        // Assert
        expect(result, Right(null));
        verify(mockRemoteDatasource.activateService(tServiceId));
        verifyNoMoreInteractions(mockRemoteDatasource);
      });

      test('should return Left(Failure) when remote datasource throws ServerException', () async {
        // Arrange
        when(mockRemoteDatasource.activateService(any)).thenThrow(tServerException);
        // Act
        final result = await repository.activateService(tServiceId);
        // Assert
        expect(result, Left(tRepositoryFailure));
        verify(mockRemoteDatasource.activateService(tServiceId));
        verifyNoMoreInteractions(mockRemoteDatasource);
      });
    });

    group('deactivateService', () {
      test('should return Right(null) when remote datasource is successful', () async {
        // Arrange
        when(mockRemoteDatasource.deactivateService(any)).thenAnswer((_) async => Future.value());
        // Act
        final result = await repository.deactivateService(tServiceId);
        // Assert
        expect(result, Right(null));
        verify(mockRemoteDatasource.deactivateService(tServiceId));
        verifyNoMoreInteractions(mockRemoteDatasource);
      });

      test('should return Left(Failure) when remote datasource throws ServerException', () async {
        // Arrange
        when(mockRemoteDatasource.deactivateService(any)).thenThrow(tServerException);
        // Act
        final result = await repository.deactivateService(tServiceId);
        // Assert
        expect(result, Left(tRepositoryFailure));
        verify(mockRemoteDatasource.deactivateService(tServiceId));
        verifyNoMoreInteractions(mockRemoteDatasource);
      });
    });
    
    group('hardDeleteService', () {
      test('should return Right(null) when remote datasource is successful', () async {
        // Arrange
        when(mockRemoteDatasource.hardDeleteService(any)).thenAnswer((_) async => Future.value());
        // Act
        final result = await repository.hardDeleteService(tServiceId);
        // Assert
        expect(result, Right(null));
        verify(mockRemoteDatasource.hardDeleteService(tServiceId));
        verifyNoMoreInteractions(mockRemoteDatasource);
      });

      test('should return Left(Failure) when remote datasource throws ServerException', () async {
        // Arrange
        when(mockRemoteDatasource.hardDeleteService(any)).thenThrow(tServerException);
        // Act
        final result = await repository.hardDeleteService(tServiceId);
        // Assert
        expect(result, Left(tRepositoryFailure));
        verify(mockRemoteDatasource.hardDeleteService(tServiceId));
        verifyNoMoreInteractions(mockRemoteDatasource);
      });
    });

    group('updateService', () {
      final tServiceInput = Service(
        id: 1, 
        name: 'Updated Service',
        description: 'Updated Desc',
        price: 150,
      );

      test('should call updateService on datasource with correctly constructed ServiceModel and return Right(null)', () async {
        // Arrange
        when(mockRemoteDatasource.updateService(any)).thenAnswer((_) async => Future.value());
        // Act
        final result = await repository.updateService(tServiceInput);
        // Assert
        expect(result, Right(null));
        verify(mockRemoteDatasource.updateService(argThat(isA<ServiceModel>()
            .having((m) => m.id, 'id', tServiceInput.id)
            .having((m) => m.name, 'name', tServiceInput.name)
            .having((m) => m.description, 'description', tServiceInput.description)
            .having((m) => m.price, 'price', tServiceInput.price)
            .having((m) => m.updatedAt, 'updatedAt', isNotNull)
            )));
        verifyNoMoreInteractions(mockRemoteDatasource);
      });

      test('should return Left(Failure) when remote datasource throws ServerException', () async {
        // Arrange
        when(mockRemoteDatasource.updateService(any)).thenThrow(tServerException);
        // Act
        final result = await repository.updateService(tServiceInput);
        // Assert
        expect(result, Left(tRepositoryFailure));
        verify(mockRemoteDatasource.updateService(argThat(isA<ServiceModel>())));
        verifyNoMoreInteractions(mockRemoteDatasource);
      });
    });

    group('getActiveServices (uses readActiveServices from datasource)', () {
      test('should return Right(List<Service>) when remote datasource is successful', () async {
        // Arrange
        when(mockRemoteDatasource.readActiveServices()).thenAnswer((_) async => tServiceModelList);
        // Act
        final result = await repository.getActiveServices();
        // Assert
        expect(result, Right(tServiceModelList));
        verify(mockRemoteDatasource.readActiveServices());
        verifyNoMoreInteractions(mockRemoteDatasource);
      });

      test('should return Right(empty List<Service>) when remote datasource returns empty list', () async {
        // Arrange
        when(mockRemoteDatasource.readActiveServices()).thenAnswer((_) async => tEmptyServiceModelList);
        // Act
        final result = await repository.getActiveServices();
        // Assert
        expect(result, Right(tEmptyServiceModelList));
        verify(mockRemoteDatasource.readActiveServices());
        verifyNoMoreInteractions(mockRemoteDatasource);
      });

      test('should return Left(Failure) when remote datasource throws ServerException', () async {
        // Arrange
        when(mockRemoteDatasource.readActiveServices()).thenThrow(tServerException);
        // Act
        final result = await repository.getActiveServices();
        // Assert
        expect(result, Left(tRepositoryFailure));
        verify(mockRemoteDatasource.readActiveServices());
        verifyNoMoreInteractions(mockRemoteDatasource);
      });
    });
  });
}
