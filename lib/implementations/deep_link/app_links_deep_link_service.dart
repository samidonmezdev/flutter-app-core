import 'dart:async';
import 'package:app_links/app_links.dart';
import '../../services/deep_link/deep_link_service.dart';

class AppLinksDeepLinkService implements DeepLinkService {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;
  final _controller = StreamController<Uri>.broadcast();

  @override
  Future<void> init() async {
    _appLinks = AppLinks();

    _subscription = _appLinks.uriLinkStream.listen(
      (uri) => _controller.add(uri),
      onError: (_) {},
    );
  }

  @override
  Future<Uri?> getInitialLink() async {
    try {
      return await _appLinks.getInitialLink();
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<Uri> get onLink => _controller.stream;

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
