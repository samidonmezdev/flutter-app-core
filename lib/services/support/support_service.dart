abstract class SupportService {
  Future<void> openSupport();
  Future<void> openPrivacyPolicy();
  Future<void> openTermsOfService();
  Future<void> sendEmail({String? subject, String? body});
}
