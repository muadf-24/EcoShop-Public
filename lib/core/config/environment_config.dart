enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.development;

  static Environment get currentEnvironment => _currentEnvironment;

  static void setEnvironment(Environment environment) {
    _currentEnvironment = environment;
  }

  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'https://dev-api.ecoshop.com';
      case Environment.staging:
        return 'https://staging-api.ecoshop.com';
      case Environment.production:
        return 'https://api.ecoshop.com';
    }
  }

  static bool get isProduction => _currentEnvironment == Environment.production;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  static bool get isDevelopment => _currentEnvironment == Environment.development;
  
  static String get environmentName => _currentEnvironment.name;
}