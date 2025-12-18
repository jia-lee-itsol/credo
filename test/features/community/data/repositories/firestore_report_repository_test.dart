import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:credo/features/community/data/repositories/firestore_report_repository.dart';
import 'package:credo/core/error/failures.dart';
import 'package:credo/features/community/domain/failures/community_failures.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

// Note: Firestore의 sealed 클래스는 직접 상속할 수 없으므로
// mocktail의 Mock을 사용하여 인터페이스를 구현합니다.

void main() {
  late FirestoreReportRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockReportsCollection;
  late MockDocumentReference mockDocumentRef;
  late MockQuery mockQuery;
  late MockQuerySnapshot mockQuerySnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockReportsCollection = MockCollectionReference();
    mockDocumentRef = MockDocumentReference();
    mockQuery = MockQuery();
    mockQuerySnapshot = MockQuerySnapshot();
    repository = FirestoreReportRepository(firestore: mockFirestore);

    // 기본 설정
    when(() => mockFirestore.collection('reports'))
        .thenReturn(mockReportsCollection);
    when(() => mockReportsCollection.doc()).thenReturn(mockDocumentRef);
    when(() => mockDocumentRef.id).thenReturn('test-report-id');
  });

  group('FirestoreReportRepository', () {
    group('createReport', () {
      test('신고가 성공적으로 생성되어야 함', () async {
        // Arrange
        const targetType = 'post';
        const targetId = 'test-post-id';
        const reason = 'spam';
        const reporterId = 'test-reporter-id';

        when(() => mockReportsCollection.where(any(), isEqualTo: any(named: 'isEqualTo')))
            .thenReturn(mockQuery);
        when(() => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo')))
            .thenReturn(mockQuery);
        when(() => mockQuery.where(any(), isGreaterThan: any(named: 'isGreaterThan')))
            .thenReturn(mockQuery);
        when(() => mockQuery.limit(any())).thenReturn(mockQuery);
        when(() => mockQuery.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([]);
        when(() => mockDocumentRef.set(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.createReport(
          targetType: targetType,
          targetId: targetId,
          reason: reason,
          reporterId: reporterId,
        );

        // Assert
        expect(result, isA<Right<Failure, String>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함'),
          (reportId) {
            expect(reportId, isNotEmpty);
            expect(reportId, 'test-report-id');
          },
        );
        verify(() => mockDocumentRef.set(any())).called(1);
      });

      test('5분 내 중복 신고 시 ReportCreationFailure를 반환해야 함', () async {
        // Arrange
        const targetType = 'post';
        const targetId = 'test-post-id';
        const reason = 'spam';
        const reporterId = 'test-reporter-id';

        final mockQueryDoc = MockQueryDocumentSnapshot();
        when(() => mockReportsCollection.where(any(), isEqualTo: any(named: 'isEqualTo')))
            .thenReturn(mockQuery);
        when(() => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo')))
            .thenReturn(mockQuery);
        when(() => mockQuery.where(any(), isGreaterThan: any(named: 'isGreaterThan')))
            .thenReturn(mockQuery);
        when(() => mockQuery.limit(any())).thenReturn(mockQuery);
        when(() => mockQuery.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([mockQueryDoc]);

        // Act
        final result = await repository.createReport(
          targetType: targetType,
          targetId: targetId,
          reason: reason,
          reporterId: reporterId,
        );

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) {
            expect(failure, isA<ReportCreationFailure>());
          },
          (_) => fail('실패가 발생해야 함'),
        );
        verifyNever(() => mockDocumentRef.set(any()));
      });

      test('FirebaseException 발생 시 FirebaseFailure를 반환해야 함', () async {
        // Arrange
        const targetType = 'post';
        const targetId = 'test-post-id';
        const reason = 'spam';
        const reporterId = 'test-reporter-id';

        final firebaseException = FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Permission denied',
        );

        when(() => mockReportsCollection.where(any(), isEqualTo: any(named: 'isEqualTo')))
            .thenReturn(mockQuery);
        when(() => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo')))
            .thenReturn(mockQuery);
        when(() => mockQuery.where(any(), isGreaterThan: any(named: 'isGreaterThan')))
            .thenReturn(mockQuery);
        when(() => mockQuery.limit(any())).thenReturn(mockQuery);
        when(() => mockQuery.get()).thenThrow(firebaseException);

        // Act
        final result = await repository.createReport(
          targetType: targetType,
          targetId: targetId,
          reason: reason,
          reporterId: reporterId,
        );

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) {
            expect(failure, isA<FirebaseFailure>());
            expect(failure.code, 'permission-denied');
          },
          (_) => fail('실패가 발생해야 함'),
        );
      });

      test('인덱스 빌딩 중 에러는 무시하고 신고를 진행해야 함', () async {
        // Arrange
        const targetType = 'post';
        const targetId = 'test-post-id';
        const reason = 'spam';
        const reporterId = 'test-reporter-id';

        final indexException = FirebaseException(
          plugin: 'firestore',
          code: 'failed-precondition',
          message: 'The query requires an index',
        );

        when(() => mockReportsCollection.where(any(), isEqualTo: any(named: 'isEqualTo')))
            .thenReturn(mockQuery);
        when(() => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo')))
            .thenReturn(mockQuery);
        when(() => mockQuery.where(any(), isGreaterThan: any(named: 'isGreaterThan')))
            .thenReturn(mockQuery);
        when(() => mockQuery.limit(any())).thenReturn(mockQuery);
        when(() => mockQuery.get()).thenThrow(indexException);
        when(() => mockDocumentRef.set(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.createReport(
          targetType: targetType,
          targetId: targetId,
          reason: reason,
          reporterId: reporterId,
        );

        // Assert
        expect(result, isA<Right<Failure, String>>());
        result.fold(
          (failure) => fail('실패가 발생하지 않아야 함'),
          (reportId) {
            expect(reportId, isNotEmpty);
          },
        );
        verify(() => mockDocumentRef.set(any())).called(1);
      });

      test('일반 예외 발생 시 ReportCreationFailure를 반환해야 함', () async {
        // Arrange
        const targetType = 'post';
        const targetId = 'test-post-id';
        const reason = 'spam';
        const reporterId = 'test-reporter-id';

        when(() => mockReportsCollection.where(any(), isEqualTo: any(named: 'isEqualTo')))
            .thenReturn(mockQuery);
        when(() => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo')))
            .thenReturn(mockQuery);
        when(() => mockQuery.where(any(), isGreaterThan: any(named: 'isGreaterThan')))
            .thenReturn(mockQuery);
        when(() => mockQuery.limit(any())).thenReturn(mockQuery);
        when(() => mockQuery.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(() => mockQuerySnapshot.docs).thenReturn([]);
        when(() => mockDocumentRef.set(any()))
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.createReport(
          targetType: targetType,
          targetId: targetId,
          reason: reason,
          reporterId: reporterId,
        );

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) {
            expect(failure, isA<ReportCreationFailure>());
          },
          (_) => fail('실패가 발생해야 함'),
        );
      });
    });
  });
}

