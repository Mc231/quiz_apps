import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('MonetizationEvent', () {
    // ============ Purchase Flow Events ============

    group('PurchaseSheetOpenedEvent', () {
      test('creates with correct event name', () {
        const event = PurchaseSheetOpenedEvent(
          source: 'settings',
          availablePacksCount: 5,
        );

        expect(event.eventName, equals('purchase_sheet_opened'));
      });

      test('includes all required parameters', () {
        const event = PurchaseSheetOpenedEvent(
          source: 'quiz_end',
          availablePacksCount: 3,
        );

        expect(event.parameters, {
          'source': 'quiz_end',
          'available_packs_count': 3,
        });
      });

      test('includes optional triggered by feature', () {
        const event = PurchaseSheetOpenedEvent(
          source: 'locked_feature',
          availablePacksCount: 5,
          triggeredByFeature: 'premium_themes',
        );

        expect(
            event.parameters['triggered_by_feature'], equals('premium_themes'));
      });

      test('factory constructor works', () {
        final event = MonetizationEvent.purchaseSheetOpened(
          source: 'home',
          availablePacksCount: 4,
        );

        expect(event, isA<PurchaseSheetOpenedEvent>());
      });
    });

    group('PackSelectedEvent', () {
      test('creates with correct event name', () {
        const event = PackSelectedEvent(
          packId: 'pack_001',
          packName: 'Premium Pack',
          price: 4.99,
          currency: 'USD',
          packIndex: 0,
        );

        expect(event.eventName, equals('pack_selected'));
      });

      test('includes all parameters', () {
        const event = PackSelectedEvent(
          packId: 'pack_002',
          packName: 'Super Bundle',
          price: 9.99,
          currency: 'EUR',
          packIndex: 1,
        );

        expect(event.parameters, {
          'pack_id': 'pack_002',
          'pack_name': 'Super Bundle',
          'price': 9.99,
          'currency': 'EUR',
          'pack_index': 1,
        });
      });

      test('factory constructor works', () {
        final event = MonetizationEvent.packSelected(
          packId: 'pack_003',
          packName: 'Starter Pack',
          price: 1.99,
          currency: 'USD',
          packIndex: 2,
        );

        expect(event, isA<PackSelectedEvent>());
      });
    });

    group('PurchaseInitiatedEvent', () {
      test('creates with correct event name', () {
        const event = PurchaseInitiatedEvent(
          packId: 'pack_001',
          packName: 'Premium Pack',
          price: 4.99,
          currency: 'USD',
          paymentMethod: 'apple_pay',
        );

        expect(event.eventName, equals('purchase_initiated'));
      });

      test('includes all parameters', () {
        const event = PurchaseInitiatedEvent(
          packId: 'pack_002',
          packName: 'Premium Pack',
          price: 4.99,
          currency: 'USD',
          paymentMethod: 'google_play',
        );

        expect(event.parameters, {
          'pack_id': 'pack_002',
          'pack_name': 'Premium Pack',
          'price': 4.99,
          'currency': 'USD',
          'payment_method': 'google_play',
        });
      });

      test('factory constructor works', () {
        final event = MonetizationEvent.purchaseInitiated(
          packId: 'pack_001',
          packName: 'Premium Pack',
          price: 4.99,
          currency: 'USD',
          paymentMethod: 'credit_card',
        );

        expect(event, isA<PurchaseInitiatedEvent>());
      });
    });

    group('PurchaseCompletedEvent', () {
      test('creates with correct event name', () {
        const event = PurchaseCompletedEvent(
          packId: 'pack_001',
          packName: 'Premium Pack',
          price: 4.99,
          currency: 'USD',
          transactionId: 'txn_123456',
          purchaseDuration: Duration(seconds: 30),
        );

        expect(event.eventName, equals('purchase_completed'));
      });

      test('includes all required parameters', () {
        const event = PurchaseCompletedEvent(
          packId: 'pack_001',
          packName: 'Premium Pack',
          price: 4.99,
          currency: 'USD',
          transactionId: 'txn_789',
          purchaseDuration: Duration(seconds: 45),
        );

        expect(event.parameters, {
          'pack_id': 'pack_001',
          'pack_name': 'Premium Pack',
          'price': 4.99,
          'currency': 'USD',
          'transaction_id': 'txn_789',
          'purchase_duration_ms': 45000,
          'is_first_purchase': 0,
        });
      });

      test('includes is first purchase flag', () {
        const event = PurchaseCompletedEvent(
          packId: 'pack_001',
          packName: 'Premium Pack',
          price: 4.99,
          currency: 'USD',
          transactionId: 'txn_first',
          purchaseDuration: Duration(seconds: 20),
          isFirstPurchase: true,
        );

        expect(event.parameters['is_first_purchase'], equals(1));
      });

      test('factory constructor works', () {
        final event = MonetizationEvent.purchaseCompleted(
          packId: 'pack_001',
          packName: 'Premium Pack',
          price: 4.99,
          currency: 'USD',
          transactionId: 'txn_456',
          purchaseDuration: const Duration(seconds: 25),
        );

        expect(event, isA<PurchaseCompletedEvent>());
      });
    });

    group('PurchaseCancelledEvent', () {
      test('creates with correct event name', () {
        const event = PurchaseCancelledEvent(
          packId: 'pack_001',
          packName: 'Premium Pack',
          price: 4.99,
          currency: 'USD',
          cancelReason: 'user_cancelled',
          timeBeforeCancel: Duration(seconds: 10),
        );

        expect(event.eventName, equals('purchase_cancelled'));
      });

      test('includes all parameters', () {
        const event = PurchaseCancelledEvent(
          packId: 'pack_002',
          packName: 'Super Bundle',
          price: 9.99,
          currency: 'EUR',
          cancelReason: 'price_too_high',
          timeBeforeCancel: Duration(seconds: 15),
        );

        expect(event.parameters, {
          'pack_id': 'pack_002',
          'pack_name': 'Super Bundle',
          'price': 9.99,
          'currency': 'EUR',
          'cancel_reason': 'price_too_high',
          'time_before_cancel_ms': 15000,
        });
      });

      test('factory constructor works', () {
        final event = MonetizationEvent.purchaseCancelled(
          packId: 'pack_001',
          packName: 'Premium Pack',
          price: 4.99,
          currency: 'USD',
          cancelReason: 'changed_mind',
          timeBeforeCancel: const Duration(seconds: 5),
        );

        expect(event, isA<PurchaseCancelledEvent>());
      });
    });

    group('PurchaseFailedEvent', () {
      test('creates with correct event name', () {
        const event = PurchaseFailedEvent(
          packId: 'pack_001',
          packName: 'Premium Pack',
          price: 4.99,
          currency: 'USD',
          errorCode: 'PAYMENT_DECLINED',
          errorMessage: 'Payment was declined by the bank',
        );

        expect(event.eventName, equals('purchase_failed'));
      });

      test('includes all parameters', () {
        const event = PurchaseFailedEvent(
          packId: 'pack_002',
          packName: 'Super Bundle',
          price: 9.99,
          currency: 'EUR',
          errorCode: 'NETWORK_ERROR',
          errorMessage: 'Network connection lost',
        );

        expect(event.parameters, {
          'pack_id': 'pack_002',
          'pack_name': 'Super Bundle',
          'price': 9.99,
          'currency': 'EUR',
          'error_code': 'NETWORK_ERROR',
          'error_message': 'Network connection lost',
        });
      });

      test('factory constructor works', () {
        final event = MonetizationEvent.purchaseFailed(
          packId: 'pack_001',
          packName: 'Premium Pack',
          price: 4.99,
          currency: 'USD',
          errorCode: 'STORE_ERROR',
          errorMessage: 'Store not available',
        );

        expect(event, isA<PurchaseFailedEvent>());
      });
    });

    // ============ Restore Events ============

    group('RestoreInitiatedEvent', () {
      test('creates with correct event name', () {
        const event = RestoreInitiatedEvent(
          source: 'settings',
        );

        expect(event.eventName, equals('restore_initiated'));
      });

      test('includes source parameter', () {
        const event = RestoreInitiatedEvent(
          source: 'purchase_sheet',
        );

        expect(event.parameters, {
          'source': 'purchase_sheet',
        });
      });

      test('factory constructor works', () {
        final event = MonetizationEvent.restoreInitiated(
          source: 'onboarding',
        );

        expect(event, isA<RestoreInitiatedEvent>());
      });
    });

    group('RestoreCompletedEvent', () {
      test('creates with correct event name', () {
        const event = RestoreCompletedEvent(
          success: true,
          restoredCount: 3,
          restoreDuration: Duration(seconds: 5),
        );

        expect(event.eventName, equals('restore_completed'));
      });

      test('includes all required parameters', () {
        const event = RestoreCompletedEvent(
          success: true,
          restoredCount: 2,
          restoreDuration: Duration(seconds: 3),
        );

        expect(event.parameters, {
          'success': 1,
          'restored_count': 2,
          'restore_duration_ms': 3000,
        });
      });

      test('includes optional error message on failure', () {
        const event = RestoreCompletedEvent(
          success: false,
          restoredCount: 0,
          restoreDuration: Duration(seconds: 10),
          errorMessage: 'No purchases found',
        );

        expect(event.parameters['error_message'], equals('No purchases found'));
      });

      test('factory constructor works', () {
        final event = MonetizationEvent.restoreCompleted(
          success: true,
          restoredCount: 5,
          restoreDuration: const Duration(seconds: 2),
        );

        expect(event, isA<RestoreCompletedEvent>());
      });
    });

    // ============ Ad Events ============

    group('AdWatchedEvent', () {
      test('creates with correct event name', () {
        const event = AdWatchedEvent(
          adType: 'rewarded',
          adPlacement: 'quiz_end',
          watchDuration: Duration(seconds: 30),
          wasCompleted: true,
        );

        expect(event.eventName, equals('ad_watched'));
      });

      test('includes all required parameters', () {
        const event = AdWatchedEvent(
          adType: 'interstitial',
          adPlacement: 'between_quizzes',
          watchDuration: Duration(seconds: 15),
          wasCompleted: true,
        );

        expect(event.parameters, {
          'ad_type': 'interstitial',
          'ad_placement': 'between_quizzes',
          'watch_duration_ms': 15000,
          'was_completed': 1,
        });
      });

      test('includes optional reward info', () {
        const event = AdWatchedEvent(
          adType: 'rewarded',
          adPlacement: 'extra_life',
          watchDuration: Duration(seconds: 30),
          wasCompleted: true,
          rewardType: 'extra_life',
          rewardAmount: 1,
        );

        expect(event.parameters['reward_type'], equals('extra_life'));
        expect(event.parameters['reward_amount'], equals(1));
      });

      test('factory constructor works', () {
        final event = MonetizationEvent.adWatched(
          adType: 'banner',
          adPlacement: 'home_screen',
          watchDuration: const Duration(seconds: 5),
          wasCompleted: false,
        );

        expect(event, isA<AdWatchedEvent>());
      });
    });

    group('AdFailedEvent', () {
      test('creates with correct event name', () {
        const event = AdFailedEvent(
          adType: 'rewarded',
          adPlacement: 'quiz_end',
          errorCode: 'NO_FILL',
          errorMessage: 'No ads available',
          failureStage: 'load',
        );

        expect(event.eventName, equals('ad_failed'));
      });

      test('includes all parameters', () {
        const event = AdFailedEvent(
          adType: 'interstitial',
          adPlacement: 'between_quizzes',
          errorCode: 'NETWORK_ERROR',
          errorMessage: 'Network unavailable',
          failureStage: 'show',
        );

        expect(event.parameters, {
          'ad_type': 'interstitial',
          'ad_placement': 'between_quizzes',
          'error_code': 'NETWORK_ERROR',
          'error_message': 'Network unavailable',
          'failure_stage': 'show',
        });
      });

      test('factory constructor works', () {
        final event = MonetizationEvent.adFailed(
          adType: 'banner',
          adPlacement: 'home',
          errorCode: 'TIMEOUT',
          errorMessage: 'Ad load timeout',
          failureStage: 'load',
        );

        expect(event, isA<AdFailedEvent>());
      });
    });
  });

  group('MonetizationEvent base class', () {
    test('all monetization events are AnalyticsEvent', () {
      final events = <AnalyticsEvent>[
        const PurchaseSheetOpenedEvent(
          source: 'test',
          availablePacksCount: 1,
        ),
        const PackSelectedEvent(
          packId: 'test',
          packName: 'Test',
          price: 1.99,
          currency: 'USD',
          packIndex: 0,
        ),
        const PurchaseInitiatedEvent(
          packId: 'test',
          packName: 'Test',
          price: 1.99,
          currency: 'USD',
          paymentMethod: 'apple_pay',
        ),
        const PurchaseCompletedEvent(
          packId: 'test',
          packName: 'Test',
          price: 1.99,
          currency: 'USD',
          transactionId: 'txn_test',
          purchaseDuration: Duration(seconds: 10),
        ),
        const PurchaseCancelledEvent(
          packId: 'test',
          packName: 'Test',
          price: 1.99,
          currency: 'USD',
          cancelReason: 'test',
          timeBeforeCancel: Duration(seconds: 5),
        ),
        const PurchaseFailedEvent(
          packId: 'test',
          packName: 'Test',
          price: 1.99,
          currency: 'USD',
          errorCode: 'TEST',
          errorMessage: 'Test error',
        ),
        const RestoreInitiatedEvent(source: 'test'),
        const RestoreCompletedEvent(
          success: true,
          restoredCount: 1,
          restoreDuration: Duration(seconds: 2),
        ),
        const AdWatchedEvent(
          adType: 'rewarded',
          adPlacement: 'test',
          watchDuration: Duration(seconds: 30),
          wasCompleted: true,
        ),
        const AdFailedEvent(
          adType: 'rewarded',
          adPlacement: 'test',
          errorCode: 'TEST',
          errorMessage: 'Test error',
          failureStage: 'load',
        ),
      ];

      for (final event in events) {
        expect(event, isA<AnalyticsEvent>());
        expect(event.eventName, isNotEmpty);
        expect(event.parameters, isA<Map<String, dynamic>>());
      }
    });
  });
}
