class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String upload = '/upload';
  static const String pickLocation = '/pick-location';
  static const String detailPattern = '/detail/:id';
  static String detail(String id) => '/detail/$id';
}
