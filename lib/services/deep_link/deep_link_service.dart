abstract class DeepLinkService {
  Future<void> init();

  /// Uygulama kapalıyken tıklanan deep link (cold start)
  Future<Uri?> getInitialLink();

  /// Uygulama açıkken gelen deep link stream'i
  Stream<Uri> get onLink;

  void dispose();
}
