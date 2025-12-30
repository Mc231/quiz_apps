import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('ScreenViewEvent', () {
    group('HomeScreenView', () {
      test('creates with correct event name', () {
        const event = HomeScreenView(activeTab: 'play');

        expect(event.eventName, equals('screen_view'));
        expect(event.screenName, equals('home'));
        expect(event.screenClass, equals('HomeScreen'));
      });

      test('includes activeTab in parameters', () {
        const event = HomeScreenView(activeTab: 'achievements');

        expect(event.parameters, {'active_tab': 'achievements'});
      });

      test('factory constructor works', () {
        final event = ScreenViewEvent.home(activeTab: 'settings');

        expect(event, isA<HomeScreenView>());
        expect(event.screenName, equals('home'));
      });
    });

    group('PlayScreenView', () {
      test('creates with correct properties', () {
        const event = PlayScreenView(categoryCount: 5);

        expect(event.screenName, equals('play'));
        expect(event.screenClass, equals('PlayScreen'));
        expect(event.parameters, {'category_count': 5});
      });

      test('factory constructor works', () {
        final event = ScreenViewEvent.play(categoryCount: 10);

        expect(event, isA<PlayScreenView>());
        expect((event as PlayScreenView).categoryCount, equals(10));
      });
    });

    group('PlayTabbedScreenView', () {
      test('creates with correct properties', () {
        const event = PlayTabbedScreenView(tabId: 'europe', tabName: 'Europe');

        expect(event.screenName, equals('play_tabbed'));
        expect(event.parameters, {
          'tab_id': 'europe',
          'tab_name': 'Europe',
        });
      });
    });

    group('HistoryScreenView', () {
      test('creates with correct properties', () {
        const event = HistoryScreenView(sessionCount: 25);

        expect(event.screenName, equals('history'));
        expect(event.screenClass, equals('SessionHistoryScreen'));
        expect(event.parameters, {'session_count': 25});
      });
    });

    group('StatisticsScreenView', () {
      test('creates with correct properties', () {
        const event = StatisticsScreenView(
          totalSessions: 100,
          averageScore: 85.5,
        );

        expect(event.screenName, equals('statistics'));
        expect(event.screenClass, equals('StatisticsDashboard'));
        expect(event.parameters, {
          'total_sessions': 100,
          'average_score': 85.5,
        });
      });
    });

    group('AchievementsScreenView', () {
      test('creates with correct properties', () {
        const event = AchievementsScreenView(
          unlockedCount: 15,
          totalCount: 50,
          totalPoints: 1500,
        );

        expect(event.screenName, equals('achievements'));
        expect(event.parameters['unlocked_count'], equals(15));
        expect(event.parameters['total_count'], equals(50));
        expect(event.parameters['total_points'], equals(1500));
      });

      test('calculates unlock percentage correctly', () {
        const event = AchievementsScreenView(
          unlockedCount: 25,
          totalCount: 100,
          totalPoints: 2500,
        );

        expect(event.parameters['unlock_percentage'], equals('25.0'));
      });

      test('handles zero total count', () {
        const event = AchievementsScreenView(
          unlockedCount: 0,
          totalCount: 0,
          totalPoints: 0,
        );

        expect(event.parameters['unlock_percentage'], equals('0.0'));
      });
    });

    group('SettingsScreenView', () {
      test('creates with empty parameters', () {
        const event = SettingsScreenView();

        expect(event.screenName, equals('settings'));
        expect(event.parameters, isEmpty);
      });
    });

    group('QuizScreenView', () {
      test('creates with correct properties', () {
        const event = QuizScreenView(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          mode: 'standard',
          totalQuestions: 20,
        );

        expect(event.screenName, equals('quiz'));
        expect(event.parameters, {
          'quiz_id': 'quiz-123',
          'quiz_name': 'European Flags',
          'mode': 'standard',
          'total_questions': 20,
        });
      });
    });

    group('ResultsScreenView', () {
      test('creates with correct properties', () {
        const event = ResultsScreenView(
          quizId: 'quiz-123',
          quizName: 'World Flags',
          scorePercentage: 95.0,
          isPerfectScore: false,
          starRating: 3,
        );

        expect(event.screenName, equals('results'));
        expect(event.parameters['is_perfect_score'], equals(0));
        expect(event.parameters['star_rating'], equals(3));
      });

      test('marks perfect score correctly', () {
        const event = ResultsScreenView(
          quizId: 'quiz-456',
          quizName: 'Asian Flags',
          scorePercentage: 100.0,
          isPerfectScore: true,
          starRating: 3,
        );

        expect(event.parameters['is_perfect_score'], equals(1));
      });
    });

    group('SessionDetailScreenView', () {
      test('creates with correct properties', () {
        const event = SessionDetailScreenView(
          sessionId: 'session-789',
          quizName: 'African Flags',
          scorePercentage: 80.0,
          daysAgo: 3,
        );

        expect(event.screenName, equals('session_detail'));
        expect(event.parameters['days_ago'], equals(3));
      });
    });

    group('CategoryStatisticsScreenView', () {
      test('creates with correct properties', () {
        const event = CategoryStatisticsScreenView(
          categoryId: 'europe',
          categoryName: 'Europe',
          totalSessions: 15,
          averageScore: 88.5,
        );

        expect(event.screenName, equals('category_statistics'));
        expect(event.parameters, {
          'category_id': 'europe',
          'category_name': 'Europe',
          'total_sessions': 15,
          'average_score': 88.5,
        });
      });
    });

    group('ChallengesScreenView', () {
      test('creates with correct properties', () {
        const event = ChallengesScreenView(
          challengeCount: 10,
          completedCount: 7,
        );

        expect(event.screenName, equals('challenges'));
        expect(event.parameters['completion_percentage'], equals('70.0'));
      });

      test('handles zero challenges', () {
        const event = ChallengesScreenView(
          challengeCount: 0,
          completedCount: 0,
        );

        expect(event.parameters['completion_percentage'], equals('0.0'));
      });
    });

    group('PracticeScreenView', () {
      test('creates with correct properties', () {
        const event = PracticeScreenView(
          categoryId: 'asia',
          categoryName: 'Asia',
        );

        expect(event.screenName, equals('practice'));
        expect(event.parameters, {
          'category_id': 'asia',
          'category_name': 'Asia',
        });
      });
    });

    group('LeaderboardScreenView', () {
      test('creates with correct properties', () {
        const event = LeaderboardScreenView(
          leaderboardType: 'global',
          entryCount: 100,
        );

        expect(event.screenName, equals('leaderboard'));
        expect(event.parameters, {
          'leaderboard_type': 'global',
          'entry_count': 100,
        });
      });
    });

    group('AboutScreenView', () {
      test('creates with correct properties', () {
        const event = AboutScreenView(
          appVersion: '1.2.3',
          buildNumber: '45',
        );

        expect(event.screenName, equals('about'));
        expect(event.parameters, {
          'app_version': '1.2.3',
          'build_number': '45',
        });
      });
    });

    group('LicensesScreenView', () {
      test('creates with empty parameters', () {
        const event = LicensesScreenView();

        expect(event.screenName, equals('licenses'));
        expect(event.parameters, isEmpty);
      });
    });

    group('TutorialScreenView', () {
      test('creates with correct properties', () {
        const event = TutorialScreenView(
          stepIndex: 2,
          totalSteps: 5,
        );

        expect(event.screenName, equals('tutorial'));
        expect(event.parameters['step_index'], equals(2));
        expect(event.parameters['total_steps'], equals(5));
      });

      test('calculates progress percentage correctly', () {
        const event = TutorialScreenView(
          stepIndex: 1, // 0-indexed, so step 2 of 4
          totalSteps: 4,
        );

        // (1 + 1) / 4 * 100 = 50%
        expect(event.parameters['progress_percentage'], equals('50.0'));
      });

      test('handles zero total steps', () {
        const event = TutorialScreenView(
          stepIndex: 0,
          totalSteps: 0,
        );

        expect(event.parameters['progress_percentage'], equals('0.0'));
      });
    });

    group('CustomScreenView', () {
      test('creates with required properties', () {
        const event = CustomScreenView(
          name: 'continent_selection',
          className: 'ContinentSelectionScreen',
        );

        expect(event.screenName, equals('continent_selection'));
        expect(event.screenClass, equals('ContinentSelectionScreen'));
        expect(event.parameters, isEmpty);
      });

      test('includes additional parameters', () {
        const event = CustomScreenView(
          name: 'flag_detail',
          className: 'FlagDetailScreen',
          additionalParams: {
            'country_code': 'US',
            'country_name': 'United States',
          },
        );

        expect(event.parameters, {
          'country_code': 'US',
          'country_name': 'United States',
        });
      });

      test('factory constructor works', () {
        final event = ScreenViewEvent.custom(
          name: 'custom_screen',
          className: 'CustomScreen',
        );

        expect(event, isA<CustomScreenView>());
      });
    });
  });

  group('AnalyticsEvent base class', () {
    test('ScreenViewEvent is AnalyticsEvent', () {
      const event = HomeScreenView(activeTab: 'play');

      expect(event, isA<AnalyticsEvent>());
    });

    test('all event types have eventName', () {
      final events = <AnalyticsEvent>[
        const HomeScreenView(activeTab: 'play'),
        const PlayScreenView(categoryCount: 5),
        const SettingsScreenView(),
        const QuizScreenView(
          quizId: 'q1',
          quizName: 'Quiz',
          mode: 'standard',
          totalQuestions: 10,
        ),
      ];

      for (final event in events) {
        expect(event.eventName, isNotEmpty);
      }
    });

    test('all event types have parameters', () {
      final events = <AnalyticsEvent>[
        const HomeScreenView(activeTab: 'play'),
        const PlayScreenView(categoryCount: 5),
        const SettingsScreenView(),
      ];

      for (final event in events) {
        expect(event.parameters, isA<Map<String, dynamic>>());
      }
    });
  });
}
