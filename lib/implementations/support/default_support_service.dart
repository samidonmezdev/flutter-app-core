import 'package:url_launcher/url_launcher.dart';
import '../../services/support/support_service.dart';

class DefaultSupportService implements SupportService {
  final String supportEmail;
  final String privacyUrl;
  final String? termsUrl;

  DefaultSupportService({
    required this.supportEmail,
    required this.privacyUrl,
    this.termsUrl,
  });

  @override
  Future<void> openSupport() async {
    await sendEmail(subject: 'Support Request');
  }

  @override
  Future<void> openPrivacyPolicy() async {
    final uri = Uri.parse(privacyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Future<void> openTermsOfService() async {
    if (termsUrl == null) return;
    final uri = Uri.parse(termsUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Future<void> sendEmail({String? subject, String? body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
