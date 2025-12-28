import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';
import '../services/quiz_services_context.dart';

/// Export format identifier for analytics.
const String _exportFormat = 'json';


/// Configuration for [ExportDataTile].
class ExportDataTileConfig {
  /// Creates an [ExportDataTileConfig].
  const ExportDataTileConfig({
    this.showIcon = true,
    this.icon = Icons.download,
    this.onExportStarted,
    this.onExportCompleted,
    this.onExportError,
  });

  /// Whether to show the leading icon.
  final bool showIcon;

  /// The icon to display.
  final IconData icon;

  /// Callback when export starts.
  final VoidCallback? onExportStarted;

  /// Callback when export completes successfully.
  final void Function(DataExportResult result)? onExportCompleted;

  /// Callback when export fails.
  final void Function(String error)? onExportError;
}

/// A ListTile for exporting user data.
///
/// When tapped, shows a dialog explaining the export and allows
/// the user to export their data to a JSON file.
///
/// Analytics service is obtained from [QuizServicesProvider] via context.
///
/// Example:
/// ```dart
/// ExportDataTile(
///   exportService: dataExportService,
/// )
/// ```
class ExportDataTile extends StatefulWidget {
  /// Creates an [ExportDataTile].
  const ExportDataTile({
    super.key,
    required this.exportService,
    this.config = const ExportDataTileConfig(),
  });

  /// The data export service.
  final DataExportService exportService;

  /// Configuration for the tile.
  final ExportDataTileConfig config;

  @override
  State<ExportDataTile> createState() => _ExportDataTileState();
}

class _ExportDataTileState extends State<ExportDataTile> {
  bool _isExporting = false;

  /// Gets the analytics service from context.
  AnalyticsService get _analyticsService => context.screenAnalyticsService;

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    return ListTile(
      leading: widget.config.showIcon
          ? Icon(
              widget.config.icon,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      title: Text(l10n.exportData),
      subtitle: Text(l10n.exportDataDescription),
      trailing: _isExporting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
      enabled: !_isExporting,
      onTap: () => _showExportDialog(context, l10n),
    );
  }

  Future<void> _showExportDialog(
    BuildContext context,
    QuizEngineLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exportData),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.exportDataDialogMessage),
              const SizedBox(height: 16),
              Text(
                l10n.exportDataIncludes,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _buildBulletPoint(l10n.exportIncludesQuizHistory),
              _buildBulletPoint(l10n.exportIncludesAnswers),
              _buildBulletPoint(l10n.exportIncludesStatistics),
              _buildBulletPoint(l10n.exportIncludesSettings),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.export),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _performExport(context, l10n);
    }
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Future<void> _performExport(
    BuildContext context,
    QuizEngineLocalizations l10n,
  ) async {
    setState(() {
      _isExporting = true;
    });

    widget.config.onExportStarted?.call();

    final startTime = DateTime.now();

    // Track export initiated event
    _analyticsService.logEvent(
      InteractionEvent.dataExportInitiated(
        exportFormat: _exportFormat,
        sessionCount: 0, // Count determined after export
      ),
    );

    try {
      final result = await widget.exportService.exportAllData();
      final exportDuration = DateTime.now().difference(startTime);

      if (!mounted) return;

      if (result.success) {
        // Save to file and share
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/${result.suggestedFilename}');
        await file.writeAsString(result.data);

        // Track successful export
        _analyticsService.logEvent(
          InteractionEvent.dataExportCompleted(
            exportFormat: _exportFormat,
            sessionCount: result.totalItems,
            fileSizeBytes: result.data.length,
            exportDuration: exportDuration,
            success: true,
          ),
        );

        widget.config.onExportCompleted?.call(result);

        // Share the file
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: l10n.exportDataSubject,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.exportDataSuccess(result.totalItems)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        final errorMessage = result.errorMessage ?? 'Unknown error';

        // Track failed export
        _analyticsService.logEvent(
          InteractionEvent.dataExportCompleted(
            exportFormat: _exportFormat,
            sessionCount: 0,
            fileSizeBytes: 0,
            exportDuration: exportDuration,
            success: false,
            errorMessage: errorMessage,
          ),
        );

        widget.config.onExportError?.call(errorMessage);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.exportDataError),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      final exportDuration = DateTime.now().difference(startTime);

      // Track export error
      _analyticsService.logEvent(
        InteractionEvent.dataExportCompleted(
          exportFormat: _exportFormat,
          sessionCount: 0,
          fileSizeBytes: 0,
          exportDuration: exportDuration,
          success: false,
          errorMessage: e.toString(),
        ),
      );

      widget.config.onExportError?.call(e.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportDataError),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}
