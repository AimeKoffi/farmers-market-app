class ApiConstants {
  // En développement local : http://localhost:8000/api
  // En Docker (injecté via --dart-define=API_URL=http://localhost/api au build) :
  //   les appels passent par le proxy Nginx → pas de CORS.
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000/api',
  );
  // static const String baseUrl = 'http://192.168.1.75:8000/api'; // device physique

  // Render free tier se réveille en 30-60s après inactivité
  static const int connectTimeout = 60000;
  static const int receiveTimeout = 30000;

  // Endpoints
  static const String login        = '/login';
  static const String logout       = '/logout';
  static const String me           = '/me';
  static const String farmers      = '/farmers';
  static const String farmerSearch = '/farmers/search';
  static const String products     = '/products';
  static const String categories   = '/categories';
  static const String transactions = '/transactions';
  static const String repayments   = '/repayments';
}