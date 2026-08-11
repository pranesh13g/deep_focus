import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutProvider extends ChangeNotifier {
  /// Returns true if the URL was launched successfully.
  Future<bool> launchLink(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Returns true if the email client was opened successfully.
  Future<bool> sendEmail() async {
    try {
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'praneshck7@gmail.com',
        query: 'subject=Query about Deep Focus',
      );
      return await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  Future<void> copyEmail() async {
    await Clipboard.setData(const ClipboardData(text: 'praneshck7@gmail.com'));
  }
}
