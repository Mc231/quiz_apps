import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../mocks/mock_analytics_service.dart';
import '../test_helpers.dart';

/// Mock data export service for testing.
class MockDataExportService implements DataExportService {
  bool shouldSucceed = true;
  int totalItems = 10;
  String exportData = '{"sessions": [], "settings": {}}';
  String? errorMessage;

  @override
  Future<DataExportResult> exportAllData({
    DataExportConfig config = DataExportConfig.full,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (shouldSucceed) {
      return DataExportResult(
        success: true,
        data: exportData,
        exportedAt: DateTime.now(),
        itemCounts: {'sessions': totalItems},
      );
    } else {
      return DataExportResult(
        success: false,
        data: '',
        errorMessage: errorMessage ?? 'Export failed',
        exportedAt: DateTime.now(),
        itemCounts: {},
      );
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExportDataTile Analytics Integration', () {
    late MockDataExportService exportService;
    late MockAnalyticsService analyticsService;

    setUp(() async {
      exportService = MockDataExportService();
      analyticsService = MockAnalyticsService();
      await analyticsService.initialize();
    });

    tearDown(() {
      analyticsService.dispose();
    });

    testWidgets('tracks export initiated event', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ExportDataTile(
            exportService: exportService,
            analyticsService: analyticsService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the tile to open dialog
      final tile = find.byType(ExportDataTile);
      await tester.tap(tile);
      await tester.pumpAndSettle();

      // Confirm export
      final exportButton = find.widgetWithText(FilledButton, 'Export');
      await tester.tap(exportButton);
      await tester.pump();

      // Verify export initiated event was logged
      final initiatedEvents = analyticsService.loggedEvents
          .whereType<InteractionEvent>()
          .where((e) => e.eventName == 'interaction_data_export_initiated')
          .toList();

      expect(initiatedEvents.length, 1);
      final event = initiatedEvents.first;
      expect(event.parameters['export_format'], 'json');
      expect(event.parameters['session_count'], 0); // Not determined yet
    });

    testWidgets('tracks successful export completion', (tester) async {
      exportService.shouldSucceed = true;
      exportService.totalItems = 42;

      await tester.pumpWidget(
        wrapWithLocalizations(
          ExportDataTile(
            exportService: exportService,
            analyticsService: analyticsService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open and confirm export
      await tester.tap(find.byType(ExportDataTile));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Export'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify export completed event was logged
      final completedEvents = analyticsService.loggedEvents
          .whereType<InteractionEvent>()
          .where((e) => e.eventName == 'interaction_data_export_completed')
          .toList();

      expect(completedEvents.length, 1);
      final event = completedEvents.first;
      expect(event.parameters['export_format'], 'json');
      expect(event.parameters['session_count'], 42);
      expect(event.parameters['success'], true);
      expect(event.parameters.containsKey('file_size_bytes'), true);
      expect(event.parameters.containsKey('export_duration'), true);

      final fileSize = event.parameters['file_size_bytes'] as int;
      expect(fileSize, greaterThan(0));

      final duration = event.parameters['export_duration'] as Duration;
      expect(duration.inMilliseconds, greaterThan(0));
    });

    testWidgets('tracks failed export', (tester) async {
      exportService.shouldSucceed = false;
      exportService.errorMessage = 'Database connection failed';

      await tester.pumpWidget(
        wrapWithLocalizations(
          ExportDataTile(
            exportService: exportService,
            analyticsService: analyticsService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open and confirm export
      await tester.tap(find.byType(ExportDataTile));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Export'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify export completed event was logged with failure
      final completedEvents = analyticsService.loggedEvents
          .whereType<InteractionEvent>()
          .where((e) => e.eventName == 'interaction_data_export_completed')
          .toList();

      expect(completedEvents.length, 1);
      final event = completedEvents.first;
      expect(event.parameters['success'], false);
      expect(event.parameters['session_count'], 0);
      expect(event.parameters['file_size_bytes'], 0);
      expect(event.parameters['error_message'], 'Database connection failed');
    });

    testWidgets('tracks export with different file sizes', (tester) async {
      exportService.shouldSucceed = true;
      exportService.totalItems = 100;
      exportService.exportData = '{"data": "${List.filled(1000, 'x').join()}"}';

      await tester.pumpWidget(
        wrapWithLocalizations(
          ExportDataTile(
            exportService: exportService,
            analyticsService: analyticsService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Perform export
      await tester.tap(find.byType(ExportDataTile));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Export'));
      await tester.pump();
      await tester.pumpAndSettle();

      final completedEvents = analyticsService.loggedEvents
          .whereType<InteractionEvent>()
          .where((e) => e.eventName == 'interaction_data_export_completed')
          .toList();

      final event = completedEvents.first;
      expect(event.parameters['session_count'], 100);

      // File size should match the export data length
      final fileSize = event.parameters['file_size_bytes'] as int;
      expect(fileSize, exportService.exportData.length);
    });

    testWidgets('does not track when analytics service is null',
        (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ExportDataTile(
            exportService: exportService,
            analyticsService: NoOpAnalyticsService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Perform export
      await tester.tap(find.byType(ExportDataTile));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Export'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify no events were logged
      expect(analyticsService.loggedEvents, isEmpty);
    });

    testWidgets('tracks export duration accurately', (tester) async {
      exportService.shouldSucceed = true;

      await tester.pumpWidget(
        wrapWithLocalizations(
          ExportDataTile(
            exportService: exportService,
            analyticsService: analyticsService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Perform export
      await tester.tap(find.byType(ExportDataTile));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Export'));
      await tester.pump();
      await tester.pumpAndSettle();

      final completedEvents = analyticsService.loggedEvents
          .whereType<InteractionEvent>()
          .where((e) => e.eventName == 'interaction_data_export_completed')
          .toList();

      final event = completedEvents.first;
      final duration = event.parameters['export_duration'] as Duration;

      // Should be at least 100ms (our mock delay)
      expect(duration.inMilliseconds, greaterThanOrEqualTo(100));
      // But not unreasonably long
      expect(duration.inSeconds, lessThan(10));
    });

    testWidgets('tracks both initiated and completed events', (tester) async {
      exportService.shouldSucceed = true;

      await tester.pumpWidget(
        wrapWithLocalizations(
          ExportDataTile(
            exportService: exportService,
            analyticsService: analyticsService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Perform export
      await tester.tap(find.byType(ExportDataTile));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Export'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify both events were logged
      final allEvents =
          analyticsService.loggedEvents.whereType<InteractionEvent>().toList();

      expect(allEvents.length, 2);
      expect(allEvents[0].eventName, 'interaction_data_export_initiated');
      expect(allEvents[1].eventName, 'interaction_data_export_completed');
    });

    testWidgets('does not track completion when dialog is cancelled',
        (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ExportDataTile(
            exportService: exportService,
            analyticsService: analyticsService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byType(ExportDataTile));
      await tester.pumpAndSettle();

      // Cancel instead of exporting
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Verify no events were logged
      expect(analyticsService.loggedEvents, isEmpty);
    });

    testWidgets('tracks export with callbacks', (tester) async {
      bool startedCalled = false;
      DataExportResult? completedResult;
      String? error;

      final config = ExportDataTileConfig(
        onExportStarted: () => startedCalled = true,
        onExportCompleted: (result) => completedResult = result,
        onExportError: (e) => error = e,
      );

      exportService.shouldSucceed = true;
      exportService.totalItems = 25;

      await tester.pumpWidget(
        wrapWithLocalizations(
          ExportDataTile(
            exportService: exportService,
            analyticsService: analyticsService,
            config: config,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Perform export
      await tester.tap(find.byType(ExportDataTile));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Export'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify callbacks were called
      expect(startedCalled, true);
      expect(completedResult, isNotNull);
      expect(completedResult!.totalItems, 25);
      expect(error, isNull);

      // Verify analytics events were still logged
      expect(analyticsService.loggedEvents.length, 2);
    });
  });
}
