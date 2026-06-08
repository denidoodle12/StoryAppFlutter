class AppConfig {
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'free',
  );

  static bool get isFree => flavor == 'free';
  static bool get isPaid => flavor == 'paid';

  static String get appName => isPaid ? 'Story App Premium' : 'Story App';
}
