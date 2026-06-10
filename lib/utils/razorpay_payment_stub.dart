void openRazorpayWebImpl({
  required Map<String, dynamic> options,
  required Function(String paymentId, String orderId, String signature) onSuccess,
  required Function(String error) onFailure,
}) {
  throw UnsupportedError('Razorpay Web is not supported on this platform.');
}
