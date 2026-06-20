import 'package:url_launcher/url_launcher.dart';

class UpiService {
  static String upiId = 'YOUR_UPI_ID@upi';
  static const String payeeName = 'BreakoutTrade';

  /// Launches UPI payment using deep link. Returns true if an external app opened.
  static Future<bool> launchUpiPayment({
    required double amount,
    required String transactionNote,
    required String transactionRef,
  }) async {
    final uri = Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': upiId,
        'pn': payeeName,
        'am': amount.toStringAsFixed(2),
        'cu': 'INR',
        'tn': transactionNote,
        'tr': transactionRef,
      },
    );
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }
}
