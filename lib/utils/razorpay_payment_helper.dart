import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:mrcoach/services/api_service.dart';

import 'razorpay_payment_stub.dart'
    if (dart.library.js_util) 'razorpay_payment_web.dart'
    if (dart.library.html) 'razorpay_payment_web.dart';

void openRazorpayWeb({
  required Map<String, dynamic> options,
  required Function(String paymentId, String orderId, String signature) onSuccess,
  required Function(String error) onFailure,
}) {
  openRazorpayWebImpl(
    options: options,
    onSuccess: onSuccess,
    onFailure: onFailure,
  );
}

class RazorpayPaymentFlow {
  static void start({
    required BuildContext context,
    required double price,
    required String contact,
    required String email,
    required VoidCallback onSuccess,
    required VoidCallback onCancel,
  }) async {
    // 1. Create order on backend
    final orderRes = await ApiService.createRazorpayOrder(price);
    if (!orderRes['success']) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderRes['message'] ?? 'Payment error'),
            backgroundColor: Colors.red,
          ),
        );
      }
      onCancel();
      return;
    }

    final options = {
      'key': orderRes['key'] ?? 'rzp_test_YOUR_KEY_ID',
      'amount': price * 100,
      'name': 'MrCoach',
      'order_id': orderRes['orderId'],
      'description': 'Demo Session Booking',
      'prefill': {
        'contact': contact,
        'email': email,
      }
    };

    if (kIsWeb) {
      openRazorpayWeb(
        options: options,
        onSuccess: (paymentId, orderId, signature) => onSuccess(),
        onFailure: (errorMsg) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment Failed: $errorMsg'),
                backgroundColor: Colors.red,
              ),
            );
          }
          onCancel();
        },
      );
    } else {
      final razorpay = Razorpay();
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse res) {
        razorpay.clear();
        onSuccess();
      });
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse res) {
        razorpay.clear();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment Failed: ${res.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        onCancel();
      });
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse res) {
        razorpay.clear();
        onCancel();
      });

      try {
        razorpay.open(options);
      } catch (e) {
        razorpay.clear();
        debugPrint('Error opening Razorpay: $e');
        onCancel();
      }
    }
  }
}
