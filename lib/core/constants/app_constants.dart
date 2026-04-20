class AppConstants {
  // Prevent instantiation — this class is never meant to be created as an object.
  // You always access it as AppConstants.appName, never as AppConstants().appName
  AppConstants._();

  // App identity
  static const String appName = 'SmartCampus';

  // Base URL for JSONPlaceholder — our fake REST API for development
  // In a real app, this would point to your university's backend
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // API endpoints — appended to baseUrl to form the full request URL
  // /posts will serve as our Announcements data
  static const String postsEndpoint = '/posts';
  // /todos will serve as our Events data
  static const String todosEndpoint = '/todos';
  // /users will serve as our user/timetable data
  static const String usersEndpoint = '/users';

  // How long to wait for an API response before giving up (in seconds)
  static const int connectionTimeout = 10;
  static const int receiveTimeout = 10;

  // SharedPreferences keys — used when saving/reading user settings
  static const String keyDarkMode = 'dark_mode';
  static const String keyNotifications = 'notifications_enabled';
  static const String keyLanguage = 'language';
}
