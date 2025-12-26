import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/theme/game_resource_theme.dart';

void main() {
  group('GameResourceTheme', () {
    group('factory constructors', () {
      test('standard() creates theme with default values', () {
        final theme = GameResourceTheme.standard();

        expect(theme.buttonSize, 48);
        expect(theme.iconSize, 24);
        expect(theme.badgeSize, 20);
        expect(theme.elevation, 2);
        expect(theme.enablePulseOnLastResource, true);
        expect(theme.enableShakeOnDepletion, true);
      });

      test('compact() creates theme with smaller sizes', () {
        final theme = GameResourceTheme.compact();

        expect(theme.buttonSize, 40);
        expect(theme.iconSize, 20);
        expect(theme.badgeSize, 16);
        expect(theme.elevation, 0);
        expect(theme.buttonBackgroundColor, Colors.transparent);
      });

      test('fromColorScheme() uses scheme colors', () {
        const scheme = ColorScheme.light(
          error: Colors.red,
          primary: Colors.blue,
          tertiary: Colors.orange,
          outline: Colors.grey,
          onPrimary: Colors.white,
          surfaceContainerHighest: Colors.black12,
          surface: Colors.white,
        );

        final theme = GameResourceTheme.fromColorScheme(scheme);

        expect(theme.livesColor, Colors.red);
        expect(theme.fiftyFiftyColor, Colors.blue);
        expect(theme.skipColor, Colors.orange);
        expect(theme.disabledColor, Colors.grey);
      });
    });

    group('getResourceColor', () {
      test('returns correct color for lives', () {
        final theme = GameResourceTheme.standard();
        expect(theme.getResourceColor(GameResourceType.lives),
            const Color(0xFFE53935));
      });

      test('returns correct color for fiftyFifty', () {
        final theme = GameResourceTheme.standard();
        expect(theme.getResourceColor(GameResourceType.fiftyFifty),
            const Color(0xFF1E88E5));
      });

      test('returns correct color for skip', () {
        final theme = GameResourceTheme.standard();
        expect(theme.getResourceColor(GameResourceType.skip),
            const Color(0xFFFB8C00));
      });
    });

    group('responsive sizing', () {
      test('getButtonSize returns correct sizes for each screen type', () {
        final theme = GameResourceTheme.standard();

        expect(theme.getButtonSize(ScreenType.watch), 36);
        expect(theme.getButtonSize(ScreenType.mobile), 48);
        expect(theme.getButtonSize(ScreenType.tablet), 56);
        expect(theme.getButtonSize(ScreenType.desktop), 56);
      });

      test('getIconSize returns correct sizes for each screen type', () {
        final theme = GameResourceTheme.standard();

        expect(theme.getIconSize(ScreenType.watch), 18);
        expect(theme.getIconSize(ScreenType.mobile), 24);
        expect(theme.getIconSize(ScreenType.tablet), 28);
        expect(theme.getIconSize(ScreenType.desktop), 28);
      });

      test('getBadgeSize returns correct sizes for each screen type', () {
        final theme = GameResourceTheme.standard();

        expect(theme.getBadgeSize(ScreenType.watch), 16);
        expect(theme.getBadgeSize(ScreenType.mobile), 20);
        expect(theme.getBadgeSize(ScreenType.tablet), 24);
        expect(theme.getBadgeSize(ScreenType.desktop), 24);
      });

      test('getBadgeFontSize scales proportionally', () {
        final theme = GameResourceTheme.standard();

        // Mobile is baseline (ratio = 1.0)
        expect(theme.getBadgeFontSize(ScreenType.mobile), 11);

        // Tablet badge is 24/20 = 1.2 ratio
        expect(theme.getBadgeFontSize(ScreenType.tablet), closeTo(13.2, 0.01));
      });

      test('compact theme has smaller responsive sizes', () {
        final theme = GameResourceTheme.compact();

        expect(theme.getButtonSize(ScreenType.mobile), 40);
        expect(theme.getButtonSize(ScreenType.tablet), 44);
        expect(theme.getIconSize(ScreenType.mobile), 20);
        expect(theme.getBadgeSize(ScreenType.mobile), 16);
      });
    });

    group('copyWith', () {
      test('creates copy with specified values changed', () {
        final original = GameResourceTheme.standard();
        final copy = original.copyWith(
          buttonSize: 60,
          livesColor: Colors.pink,
          enablePulseOnLastResource: false,
        );

        expect(copy.buttonSize, 60);
        expect(copy.livesColor, Colors.pink);
        expect(copy.enablePulseOnLastResource, false);

        // Other values should remain unchanged
        expect(copy.iconSize, original.iconSize);
        expect(copy.fiftyFiftyColor, original.fiftyFiftyColor);
      });

      test('creates identical copy when no values specified', () {
        final original = GameResourceTheme.standard();
        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('equality', () {
      test('two standard themes are equal', () {
        final theme1 = GameResourceTheme.standard();
        final theme2 = GameResourceTheme.standard();

        expect(theme1, equals(theme2));
        expect(theme1.hashCode, equals(theme2.hashCode));
      });

      test('themes with different values are not equal', () {
        final theme1 = GameResourceTheme.standard();
        final theme2 = theme1.copyWith(buttonSize: 60);

        expect(theme1, isNot(equals(theme2)));
      });

      test('standard and compact themes are not equal', () {
        final standard = GameResourceTheme.standard();
        final compact = GameResourceTheme.compact();

        expect(standard, isNot(equals(compact)));
      });
    });
  });

  group('GameResourceType', () {
    test('has all expected values', () {
      expect(GameResourceType.values.length, 3);
      expect(GameResourceType.values, contains(GameResourceType.lives));
      expect(GameResourceType.values, contains(GameResourceType.fiftyFifty));
      expect(GameResourceType.values, contains(GameResourceType.skip));
    });
  });

  group('ScreenType', () {
    test('has all expected values', () {
      expect(ScreenType.values.length, 4);
      expect(ScreenType.values, contains(ScreenType.mobile));
      expect(ScreenType.values, contains(ScreenType.tablet));
      expect(ScreenType.values, contains(ScreenType.desktop));
      expect(ScreenType.values, contains(ScreenType.watch));
    });
  });

  group('ScreenTypeExtension on Size', () {
    test('returns watch for width < 300', () {
      expect(const Size(200, 300).screenType, ScreenType.watch);
      expect(const Size(299, 400).screenType, ScreenType.watch);
    });

    test('returns mobile for width 300-599', () {
      expect(const Size(300, 600).screenType, ScreenType.mobile);
      expect(const Size(599, 800).screenType, ScreenType.mobile);
    });

    test('returns tablet for width 600-1023', () {
      expect(const Size(600, 800).screenType, ScreenType.tablet);
      expect(const Size(1023, 768).screenType, ScreenType.tablet);
    });

    test('returns desktop for width >= 1024', () {
      expect(const Size(1024, 768).screenType, ScreenType.desktop);
      expect(const Size(1920, 1080).screenType, ScreenType.desktop);
    });
  });
}
