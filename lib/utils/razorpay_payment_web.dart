import 'dart:js' as js;
import 'dart:convert';

void openRazorpayWebImpl({
  required Map<String, dynamic> options,
  required Function(String paymentId, String orderId, String signature) onSuccess,
  required Function(String error) onFailure,
}) {
  try {
    js.context.callMethod('openRazorpay', [
      jsonEncode(options),
      js.allowInterop((paymentId, orderId, signature) {
        onSuccess(
          paymentId?.toString() ?? '',
          orderId?.toString() ?? '',
          signature?.toString() ?? '',
        );
      }),
      js.allowInterop((errorMsg) {
        onFailure(errorMsg?.toString() ?? 'Payment dismissed');
      }),
    ]);
  } catch (e) {
    onFailure('Error calling Web Razorpay: $e');
  }
}
