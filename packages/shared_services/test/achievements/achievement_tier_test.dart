import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('AchievementTier', () {
    test('has correct number of values', () {
      expect(AchievementTier.values.length, 5);
    });

    test('values are in correct order', () {
      expect(AchievementTier.values[0], AchievementTier.common);
      expect(AchievementTier.values[1], AchievementTier.uncommon);
      expect(AchievementTier.values[2], AchievementTier.rare);
      expect(AchievementTier.values[3], AchievementTier.epic);
      expect(AchievementTier.values[4], AchievementTier.legendary);
    });
  });

  group('AchievementTierExtension', () {
    group('color', () {
      test('common has bronze color', () {
        expect(AchievementTier.common.color, const Color(0xFFCD7F32));
      });

      test('uncommon has silver color', () {
        expect(AchievementTier.uncommon.color, const Color(0xFFC0C0C0));
      });

      test('rare has gold color', () {
        expect(AchievementTier.rare.color, const Color(0xFFFFD700));
      });

      test('epic has purple color', () {
        expect(AchievementTier.epic.color, const Color(0xFF9B59B6));
      });

      test('legendary has diamond color', () {
        expect(AchievementTier.legendary.color, const Color(0xFF00D9FF));
      });
    });

    group('icon', () {
      test('common has bronze medal icon', () {
        expect(AchievementTier.common.icon, '🥉');
      });

      test('uncommon has silver medal icon', () {
        expect(AchievementTier.uncommon.icon, '🥈');
      });

      test('rare has gold medal icon', () {
        expect(AchievementTier.rare.icon, '🥇');
      });

      test('epic has purple heart icon', () {
        expect(AchievementTier.epic.icon, '💜');
      });

      test('legendary has diamond icon', () {
        expect(AchievementTier.legendary.icon, '💎');
      });
    });

    group('label', () {
      test('all tiers have correct labels', () {
        expect(AchievementTier.common.label, 'Common');
        expect(AchievementTier.uncommon.label, 'Uncommon');
        expect(AchievementTier.rare.label, 'Rare');
        expect(AchievementTier.epic.label, 'Epic');
        expect(AchievementTier.legendary.label, 'Legendary');
      });
    });

    group('points', () {
      test('common gives 10 points', () {
        expect(AchievementTier.common.points, 10);
      });

      test('uncommon gives 25 points', () {
        expect(AchievementTier.uncommon.points, 25);
      });

      test('rare gives 50 points', () {
        expect(AchievementTier.rare.points, 50);
      });

      test('epic gives 100 points', () {
        expect(AchievementTier.epic.points, 100);
      });

      test('legendary gives 250 points', () {
        expect(AchievementTier.legendary.points, 250);
      });
    });

    group('isHidden', () {
      test('common is not hidden', () {
        expect(AchievementTier.common.isHidden, false);
      });

      test('uncommon is not hidden', () {
        expect(AchievementTier.uncommon.isHidden, false);
      });

      test('rare is not hidden', () {
        expect(AchievementTier.rare.isHidden, false);
      });

      test('epic is hidden', () {
        expect(AchievementTier.epic.isHidden, true);
      });

      test('legendary is hidden', () {
        expect(AchievementTier.legendary.isHidden, true);
      });
    });

    group('sortIndex', () {
      test('common has lowest sort index', () {
        expect(AchievementTier.common.sortIndex, 0);
      });

      test('legendary has highest sort index', () {
        expect(AchievementTier.legendary.sortIndex, 4);
      });

      test('sort indices are sequential', () {
        for (int i = 0; i < AchievementTier.values.length; i++) {
          expect(AchievementTier.values[i].sortIndex, i);
        }
      });
    });
  });
}
