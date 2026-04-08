import 'dart:async';

typedef EventCallback = void Function(dynamic data);

class AppEventBus {
  AppEventBus._();
  static final AppEventBus instance = AppEventBus._();

  final _controller = StreamController<_AppEvent>.broadcast();

  void emit(String event, {dynamic data}) {
    _controller.add(_AppEvent(event, data));
  }

  StreamSubscription on(String event, EventCallback callback) {
    return _controller.stream
        .where((e) => e.name == event)
        .listen((e) => callback(e.data));
  }

  void dispose() {
    _controller.close();
  }
}

class _AppEvent {
  final String name;
  final dynamic data;
  _AppEvent(this.name, this.data);
}
