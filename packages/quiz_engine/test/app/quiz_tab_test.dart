import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/app/quiz_tab.dart';
import 'package:quiz_engine/src/l10n/quiz_localizations_delegate.dart';

void main() {
  group('QuizTab', () {
    group('Factory methods', () {
      test('QuizTab.play() creates PlayTab', () {
        final tab = QuizTab.play();

        expect(tab, isA<PlayTab>());
        expect(tab.id, 'play');
        expect(tab.icon, PlayTab.defaultIcon);
        expect(tab.selectedIcon, PlayTab.defaultSelectedIcon);
      });

      test('QuizTab.history() creates HistoryTab', () {
        final tab = QuizTab.history();

        expect(tab, isA<HistoryTab>());
        expect(tab.id, 'history');
        expect(tab.icon, HistoryTab.defaultIcon);
        expect(tab.selectedIcon, HistoryTab.defaultSelectedIcon);
      });

      test('QuizTab.statistics() creates StatisticsTab', () {
        final tab = QuizTab.statistics();

        expect(tab, isA<StatisticsTab>());
        expect(tab.id, 'statistics');
        expect(tab.icon, StatisticsTab.defaultIcon);
        expect(tab.selectedIcon, StatisticsTab.defaultSelectedIcon);
      });

      test('QuizTab.settings() creates SettingsTab', () {
        final tab = QuizTab.settings();

        expect(tab, isA<SettingsTab>());
        expect(tab.id, 'settings');
        expect(tab.icon, SettingsTab.defaultIcon);
        expect(tab.selectedIcon, SettingsTab.defaultSelectedIcon);
      });

      test('QuizTab.custom() creates CustomTab', () {
        final tab = QuizTab.custom(
          id: 'leaderboard',
          icon: Icons.leaderboard_outlined,
          selectedIcon: Icons.leaderboard,
          labelBuilder: (context) => 'Leaderboard',
          builder: (context) => const SizedBox(),
        );

        expect(tab, isA<CustomTab>());
        expect(tab.id, 'leaderboard');
        expect(tab.icon, Icons.leaderboard_outlined);
        expect(tab.selectedIcon, Icons.leaderboard);
      });
    });

    group('Custom label builders', () {
      test('PlayTab accepts custom label builder', () {
        final tab = QuizTab.play(labelBuilder: (context) => 'Custom Play');

        expect(tab.id, 'play');
        // Label is resolved with context later
      });

      test('HistoryTab accepts custom label builder', () {
        final tab = QuizTab.history(labelBuilder: (context) => 'Custom History');

        expect(tab.id, 'history');
      });

      test('StatisticsTab accepts custom label builder', () {
        final tab = QuizTab.statistics(labelBuilder: (context) => 'Custom Stats');

        expect(tab.id, 'statistics');
      });

      test('SettingsTab accepts custom label builder', () {
        final tab = QuizTab.settings(labelBuilder: (context) => 'Custom Settings');

        expect(tab.id, 'settings');
      });
    });

    group('effectiveSelectedIcon', () {
      test('returns selectedIcon when provided', () {
        final tab = QuizTab.play();

        expect(tab.effectiveSelectedIcon, PlayTab.defaultSelectedIcon);
      });

      test('returns icon when selectedIcon is null', () {
        final tab = QuizTab.custom(
          id: 'test',
          icon: Icons.star,
          labelBuilder: (context) => 'Test',
          builder: (context) => const SizedBox(),
        );

        expect(tab.effectiveSelectedIcon, Icons.star);
      });
    });

    group('Equality', () {
      test('tabs with same id are equal', () {
        final tab1 = QuizTab.play();
        final tab2 = QuizTab.play();

        expect(tab1 == tab2, isTrue);
        expect(tab1.hashCode, tab2.hashCode);
      });

      test('tabs with different id are not equal', () {
        final tab1 = QuizTab.play();
        final tab2 = QuizTab.history();

        expect(tab1 == tab2, isFalse);
      });

      test('custom tabs with same id are equal', () {
        final tab1 = QuizTab.custom(
          id: 'custom1',
          icon: Icons.star,
          labelBuilder: (context) => 'Test 1',
          builder: (context) => const SizedBox(),
        );
        final tab2 = QuizTab.custom(
          id: 'custom1',
          icon: Icons.circle,
          labelBuilder: (context) => 'Test 2',
          builder: (context) => Container(),
        );

        expect(tab1 == tab2, isTrue);
      });
    });

    group('toString', () {
      test('returns readable format', () {
        expect(QuizTab.play().toString(), 'QuizTab(play)');
        expect(QuizTab.history().toString(), 'QuizTab(history)');
        expect(QuizTab.statistics().toString(), 'QuizTab(statistics)');
        expect(QuizTab.settings().toString(), 'QuizTab(settings)');
      });
    });

    testWidgets('labelBuilder resolves with context', (tester) async {
      final tab = QuizTab.play(labelBuilder: (context) => 'Localized Play');

      String? label;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              label = tab.labelBuilder(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(label, 'Localized Play');
    });

    testWidgets('default labels resolve correctly', (tester) async {
      final playTab = QuizTab.play();
      final historyTab = QuizTab.history();
      final statisticsTab = QuizTab.statistics();
      final settingsTab = QuizTab.settings();

      String? playLabel;
      String? historyLabel;
      String? statsLabel;
      String? settingsLabel;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            QuizLocalizationsDelegate(),
          ],
          home: Builder(
            builder: (context) {
              playLabel = playTab.labelBuilder(context);
              historyLabel = historyTab.labelBuilder(context);
              statsLabel = statisticsTab.labelBuilder(context);
              settingsLabel = settingsTab.labelBuilder(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(playLabel, 'Play');
      expect(historyLabel, 'History');
      expect(statsLabel, 'Statistics');
      expect(settingsLabel, 'Settings');
    });
  });

  group('CustomTab', () {
    testWidgets('builder creates widget', (tester) async {
      final tab = QuizTab.custom(
        id: 'custom',
        icon: Icons.star,
        labelBuilder: (context) => 'Custom',
        builder: (context) => const Text('Custom Content'),
      ) as CustomTab;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return tab.builder(context);
            },
          ),
        ),
      );

      expect(find.text('Custom Content'), findsOneWidget);
    });
  });

  group('QuizTabConfig', () {
    test('creates config with required fields', () {
      final config = QuizTabConfig(
        tabs: [QuizTab.play(), QuizTab.history()],
      );

      expect(config.tabs.length, 2);
      expect(config.initialIndex, 0);
      expect(config.onTabSelected, isNull);
      expect(config.preserveState, isTrue);
    });

    test('creates config with all fields', () {
      void onTabSelected(QuizTab tab, int index) {}

      final config = QuizTabConfig(
        tabs: [QuizTab.play()],
        initialIndex: 0,
        onTabSelected: onTabSelected,
        preserveState: false,
      );

      expect(config.tabs.length, 1);
      expect(config.initialIndex, 0);
      expect(config.onTabSelected, onTabSelected);
      expect(config.preserveState, isFalse);
    });

    test('defaultConfig creates play, history, statistics tabs', () {
      final config = QuizTabConfig.defaultConfig();

      expect(config.tabs.length, 3);
      expect(config.tabs[0], isA<PlayTab>());
      expect(config.tabs[1], isA<HistoryTab>());
      expect(config.tabs[2], isA<StatisticsTab>());
    });

    test('allTabs creates all standard tabs', () {
      final config = QuizTabConfig.allTabs();

      expect(config.tabs.length, 4);
      expect(config.tabs[0], isA<PlayTab>());
      expect(config.tabs[1], isA<HistoryTab>());
      expect(config.tabs[2], isA<StatisticsTab>());
      expect(config.tabs[3], isA<SettingsTab>());
    });

    test('copyWith creates new config with replaced fields', () {
      final original = QuizTabConfig.defaultConfig();

      final copied = original.copyWith(
        initialIndex: 1,
        preserveState: false,
      );

      expect(copied.tabs.length, 3); // Preserved
      expect(copied.initialIndex, 1); // Changed
      expect(copied.preserveState, isFalse); // Changed
    });

    test('copyWith preserves unspecified fields', () {
      void onTabSelected(QuizTab tab, int index) {}

      final original = QuizTabConfig(
        tabs: [QuizTab.play()],
        onTabSelected: onTabSelected,
      );

      final copied = original.copyWith(initialIndex: 1);

      expect(copied.tabs.length, 1);
      expect(copied.onTabSelected, onTabSelected);
    });
  });

  group('Sealed class pattern matching', () {
    test('can pattern match on tab types', () {
      final tabs = [
        QuizTab.play(),
        QuizTab.history(),
        QuizTab.statistics(),
        QuizTab.settings(),
        QuizTab.achievements(),
        QuizTab.custom(
          id: 'custom',
          icon: Icons.star,
          labelBuilder: (context) => 'Custom',
          builder: (context) => const SizedBox(),
        ),
      ];

      final results = tabs.map((tab) {
        return switch (tab) {
          PlayTab() => 'play',
          HistoryTab() => 'history',
          StatisticsTab() => 'statistics',
          SettingsTab() => 'settings',
          AchievementsTab() => 'achievements',
          CustomTab() => 'custom',
        };
      }).toList();

      expect(results,
          ['play', 'history', 'statistics', 'settings', 'achievements', 'custom']);
    });
  });
}
