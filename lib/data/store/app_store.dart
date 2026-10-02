final store = AppStore();

class AppStore {
  AppStore._privateConstructor();
  factory AppStore() => _singleton;
  static final AppStore _singleton = AppStore._privateConstructor();

  late int clubNbr;
  late String mail;
  late int clubId;
  late int maxMembers;
  late double pricePerMemberYearly;

  final Map<String, int> teamIds = {};

  @override
  String toString() => '$clubNbr | $mail';
}
