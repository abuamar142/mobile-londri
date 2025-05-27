import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:londri/core/error/exceptions.dart';
import 'package:londri/features/service/data/datasources/service_remote_datasource.dart';
import 'package:londri/features/service/data/models/service_model.dart';

// Mock Supabase classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockPostgrestFilterBuilder<T> extends Mock implements PostgrestFilterBuilder<T> {}
// Removed MockPostgrestTransformBuilder as FilterBuilder is often thenable or has terminal methods.

void main() {
  late ServiceRemoteDatasourceImplementation datasource;
  late MockSupabaseClient mockSupabaseClient;
  late MockPostgrestFilterBuilder<dynamic> mockFilterBuilder; // Using dynamic for flexibility

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockFilterBuilder = MockPostgrestFilterBuilder<dynamic>();
    
    final mockAuth = MockGoTrueClient(); // Basic auth mock
    when(mockSupabaseClient.auth).thenReturn(mockAuth);

    datasource = ServiceRemoteDatasourceImplementation(supabaseClient: mockSupabaseClient);

    // Common stub for from()
    when(mockSupabaseClient.from(any)).thenReturn(mockFilterBuilder);
  });

  // Sample data
  const tServiceId = 'test-service-uuid'; // Assuming UUID string for Supabase 'id' column
  final tNow = DateTime.now();
  // ServiceModel's id is int, but Supabase 'id' might be string.
  // Let's assume the datasource handles mapping if Supabase 'id' is string and ServiceModel.id is int.
  // For these tests, tServiceJson.id will be what Supabase returns.
  final tServiceModel = ServiceModel( 
    id: 1, // This is the DB int primary key
    name: 'Test Service',
    price: 100,
    description: 'Test Description',
    createdAt: tNow,
    updatedAt: tNow,
  );

  final tServiceJson = { // This represents what Supabase returns
    'id': 1, // Supabase might return string UUID here if 'id' is UUID. Let's assume int for consistency with ServiceModel.id for now.
             // If Supabase 'id' column is different from ServiceModel 'id', this needs adjustment.
    'name': 'Test Service',
    'price': 100,
    'description': 'Test Description',
    'created_at': tNow.toIso8601String(),
    'updated_at': tNow.toIso8601String(),
    'deleted_at': null,
  };

  final tServiceListJson = [tServiceJson];

  final tPostgrestException = PostgrestException(message: 'DB error');
  final tGenericException = Exception('Something went wrong');

  group('ServiceRemoteDatasourceImplementation', () {
    group('readServices', () {
      test('should return List<ServiceModel> when the call is successful', () async {
        // Arrange
        when(mockFilterBuilder.select<List<Map<String, dynamic>>>('*')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('name', ascending: true)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then(any)).thenAnswer((_) async => tServiceListJson);

        // Act
        final result = await datasource.readServices();

        // Assert
        expect(result, isA<List<ServiceModel>>());
        expect(result.length, 1);
        expect(result.first.name, tServiceModel.name);
        verify(mockSupabaseClient.from('services')).called(1);
        verify(mockFilterBuilder.select<List<Map<String, dynamic>>>('*')).called(1);
        verify(mockFilterBuilder.order('name', ascending: true)).called(1);
        verify(mockFilterBuilder.then(any)).called(1);
        verifyNoMoreInteractions(mockSupabaseClient);
        verifyNoMoreInteractions(mockFilterBuilder);
      });

      test('should throw ServerException when PostgrestException occurs', () async {
        // Arrange
        when(mockFilterBuilder.select<List<Map<String, dynamic>>>('*')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('name', ascending: true)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then(any)).thenThrow(tPostgrestException);

        // Act & Assert
        expect(() => datasource.readServices(), throwsA(isA<ServerException>().having((e) => e.message, 'message', tPostgrestException.message)));
      });

      test('should throw ServerException when a generic Exception occurs', () async {
        // Arrange
        when(mockFilterBuilder.select<List<Map<String, dynamic>>>('*')).thenThrow(tGenericException);

        // Act & Assert
        expect(() => datasource.readServices(), throwsA(isA<ServerException>().having((e) => e.message, 'message', tGenericException.toString())));
      });
    });

    group('readActiveServices', () {
      test('should return List<ServiceModel> for active services when successful', () async {
        // Arrange
        when(mockFilterBuilder.select<List<Map<String, dynamic>>>('*')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.is_('deleted_at', null)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('name', ascending: true)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then(any)).thenAnswer((_) async => tServiceListJson);

        // Act
        final result = await datasource.readActiveServices();

        // Assert
        expect(result.first.name, tServiceModel.name);
        verify(mockFilterBuilder.is_('deleted_at', null)).called(1);
      });

      test('should throw ServerException for PostgrestException', () async {
        // Arrange
        when(mockFilterBuilder.select<List<Map<String, dynamic>>>('*')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.is_('deleted_at', null)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('name', ascending: true)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then(any)).thenThrow(tPostgrestException);
        
        // Act & Assert
        expect(() => datasource.readActiveServices(), throwsA(isA<ServerException>().having((e) => e.message, 'message', tPostgrestException.message)));
      });
    });

    group('readServiceById', () {
      test('should return ServiceModel when successful', () async {
        // Arrange
        when(mockFilterBuilder.select<Map<String, dynamic>>('*')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', tServiceId)).thenReturn(mockFilterBuilder); // tServiceId is String UUID
        when(mockFilterBuilder.single()).thenAnswer((_) async => tServiceJson);

        // Act
        final result = await datasource.readServiceById(tServiceId);

        // Assert
        expect(result.name, tServiceModel.name);
        verify(mockFilterBuilder.eq('id', tServiceId)).called(1);
        verify(mockFilterBuilder.single()).called(1);
      });

      test('should throw ServerException for PostgrestException on single()', () async {
        // Arrange
        when(mockFilterBuilder.select<Map<String, dynamic>>('*')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', tServiceId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenThrow(tPostgrestException);
        
        // Act & Assert
        expect(() => datasource.readServiceById(tServiceId), throwsA(isA<ServerException>().having((e) => e.message, 'message', tPostgrestException.message)));
      });
    });

    group('createService', () {
      final tCreateJson = tServiceModel.toJson()..remove('id')..remove('created_at')..remove('updated_at')..remove('deleted_at');

      test('should complete successfully for service creation', () async {
        // Arrange
        // cleanNulls is part of toJson in ServiceModel if implemented there, or done by datasource.
        // Assuming toJson already handles nulls appropriately or cleanNulls is used by implementation.
        when(mockFilterBuilder.insert(argThat(isA<Map<String,dynamic>>()
            .having((m) => m['name'], 'name', tServiceModel.name)
        ))).thenAnswer((_) async => []); 
        
        // Act
        await datasource.createService(tServiceModel);

        // Assert
        verify(mockFilterBuilder.insert(argThat(isA<Map<String,dynamic>>()
          .having((m) => m['name'], 'name', tServiceModel.name)
          // id should not be in the insert payload if DB generates it
          .having((m) => m.containsKey('id'), 'contains_id', isFalse) 
        ))).called(1);
      });

      test('should throw ServerException for PostgrestException on insert', () async {
        // Arrange
        when(mockFilterBuilder.insert(any)).thenThrow(tPostgrestException);
        
        // Act & Assert
        expect(() => datasource.createService(tServiceModel), throwsA(isA<ServerException>().having((e) => e.message, 'message', tPostgrestException.message)));
      });
    });

    group('updateService', () {
      // For update, 'id' is used in eq, not in payload. 'created_at' is usually not updated.
      final tUpdateJson = tServiceModel.toJson()..remove('id')..remove('created_at')..remove('deleted_at');
      
      test('should complete successfully for service update', () async {
        // Arrange
        when(mockFilterBuilder.update(argThat(isA<Map<String,dynamic>>()
          .having((m) => m['name'], 'name', tServiceModel.name)
          .having((m) => m.containsKey('id'), 'contains_id_in_payload', isFalse)
        ))).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', tServiceModel.id)).thenReturn(mockFilterBuilder); // ServiceModel.id is int
        when(mockFilterBuilder.then(any)).thenAnswer((_) async => null); // Or `async => []`

        // Act
        await datasource.updateService(tServiceModel);

        // Assert
        verify(mockFilterBuilder.update(argThat(isA<Map<String,dynamic>>()
          .having((m) => m['name'], 'name', tServiceModel.name)
          .having((m) => m.containsKey('id'), 'contains_id_in_payload', isFalse)
        ))).called(1);
        verify(mockFilterBuilder.eq('id', tServiceModel.id)).called(1);
        verify(mockFilterBuilder.then(any)).called(1);
      });

      test('should throw ServerException for PostgrestException on update', () async {
        // Arrange
        when(mockFilterBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', tServiceModel.id)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then(any)).thenThrow(tPostgrestException);

        // Act & Assert
        expect(() => datasource.updateService(tServiceModel), throwsA(isA<ServerException>().having((e) => e.message, 'message', tPostgrestException.message)));
      });
    });

    group('activateService', () {
      test('should complete successfully for activation', () async {
        // Arrange
        when(mockFilterBuilder.update({'deleted_at': null})).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', tServiceId)).thenReturn(mockFilterBuilder); // tServiceId is String UUID
        when(mockFilterBuilder.then(any)).thenAnswer((_) async => null);

        // Act
        await datasource.activateService(tServiceId);

        // Assert
        verify(mockFilterBuilder.update({'deleted_at': null})).called(1);
        verify(mockFilterBuilder.eq('id', tServiceId)).called(1);
        verify(mockFilterBuilder.then(any)).called(1);
      });

      test('should throw ServerException for PostgrestException on activate', () async {
        // Arrange
        when(mockFilterBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', tServiceId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then(any)).thenThrow(tPostgrestException);

        // Act & Assert
        expect(() => datasource.activateService(tServiceId), throwsA(isA<ServerException>().having((e) => e.message, 'message', tPostgrestException.message)));
      });
    });

    group('deactivateService', () {
      test('should complete successfully for deactivation', () async {
        // Arrange
        when(mockFilterBuilder.update(argThat(isA<Map<String, dynamic>>()
            .having((map) => map.containsKey('deleted_at') && map['deleted_at'] is String, 'deleted_at_is_string', true)
        ))).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', tServiceId)).thenReturn(mockFilterBuilder); // tServiceId is String UUID
        when(mockFilterBuilder.then(any)).thenAnswer((_) async => null);

        // Act
        await datasource.deactivateService(tServiceId);

        // Assert
        verify(mockFilterBuilder.update(argThat(isA<Map<String, dynamic>>()
            .having((map) => map.containsKey('deleted_at') && map['deleted_at'] is String, 'deleted_at_is_string', true)
        ))).called(1);
        verify(mockFilterBuilder.eq('id', tServiceId)).called(1);
        verify(mockFilterBuilder.then(any)).called(1);
      });

      test('should throw ServerException for PostgrestException on deactivate', () async {
        // Arrange
         when(mockFilterBuilder.update(argThat(isA<Map<String, dynamic>>()))).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', tServiceId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then(any)).thenThrow(tPostgrestException);

        // Act & Assert
        expect(() => datasource.deactivateService(tServiceId), throwsA(isA<ServerException>().having((e) => e.message, 'message', tPostgrestException.message)));
      });
    });

    group('hardDeleteService', () {
      test('should complete successfully for deletion', () async {
        // Arrange
        when(mockFilterBuilder.delete()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', tServiceId)).thenReturn(mockFilterBuilder); // tServiceId is String UUID
        when(mockFilterBuilder.then(any)).thenAnswer((_) async => null);
        
        // Act
        await datasource.hardDeleteService(tServiceId);

        // Assert
        verify(mockFilterBuilder.delete()).called(1);
        verify(mockFilterBuilder.eq('id', tServiceId)).called(1);
        verify(mockFilterBuilder.then(any)).called(1);
      });

      test('should throw ServerException for PostgrestException on delete', () async {
        // Arrange
        when(mockFilterBuilder.delete()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', tServiceId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then(any)).thenThrow(tPostgrestException);

        // Act & Assert
        expect(() => datasource.hardDeleteService(tServiceId), throwsA(isA<ServerException>().having((e) => e.message, 'message', tPostgrestException.message)));
      });
    });
  });
}
