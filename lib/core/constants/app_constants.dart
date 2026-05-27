class AppConstants {
  // ⚠️ Change this to your server IP or domain
  // Local testing: your computer's IP on WiFi e.g. http://192.168.1.100:3000
  // Production:    your VPS domain e.g. https://api.flamingo-app.com
  static const String serverUrl = 'http://187.127.162.23:3000';

  static const String registerEndpoint = '/api/auth/register';
  static const String loginEndpoint = '/api/auth/login';
  static const String generateCodeEndpoint = '/api/pair/generate';
  static const String childrenEndpoint = '/api/pair/children';

  static const double defaultZoom = 15.0;
}
