import 'dart:async';

final homeCtrler = HomeController();

class HomeController {
  static final HomeController _singleton = HomeController._privateConstructor();
  factory HomeController() => _singleton;
  HomeController._privateConstructor();

  final StreamController<int> _streamCtrler = StreamController<int>();

  Stream<int> get stream => _streamCtrler.stream;

  pushStream(index) => _streamCtrler.add(index);
}
