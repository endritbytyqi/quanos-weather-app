class APIBase {
  static const _apiPath = "https://api.openweathermap.org/data/2.5/weather?";
  static const String _apiKEY = String.fromEnvironment("API_KEY");

  getApiBaseURL() {
    return _apiPath;
  }

  getAPIKey() {
    return _apiKEY;
  }
}
