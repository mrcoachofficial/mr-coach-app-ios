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
