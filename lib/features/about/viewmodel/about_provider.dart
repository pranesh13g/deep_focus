import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutProvider extends ChangeNotifier {
  Future<void> launchLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'praneshck7@gmail.com',
      query: 'subject=Query about Deep Focus',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  Future<void> copyEmail() async {
    await Clipboard.setData(const ClipboardData(text: 'praneshck7@gmail.com'));
  }
}
