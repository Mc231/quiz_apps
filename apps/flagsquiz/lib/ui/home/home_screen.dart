import 'package:flags_quiz/l10n/app_localizations.dart';
import 'package:flags_quiz/ui/continents/continents_screen.dart';
import 'package:flags_quiz/ui/history/history_page.dart';
import 'package:flags_quiz/ui/statistics/statistics_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

/// Home screen with bottom navigation for Play, History, and Statistics.
class HomeScreen extends StatefulWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({
    super.key,
    required this.settingsService,
    required this.storageService,
  });

  /// Settings service for app preferences.
  final SettingsService settingsService;

  /// Storage service for quiz data.
  final StorageService storageService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ContinentsScreen(settingsService: widget.settingsService),
      HistoryPage(storageService: widget.storageService),
      StatisticsPage(storageService: widget.storageService),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.play_circle_outline),
            selectedIcon: const Icon(Icons.play_circle),
            label: l10n.play,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: l10n.history,
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics),
            label: l10n.statistics,
          ),
        ],
      ),
    );
  }
}
