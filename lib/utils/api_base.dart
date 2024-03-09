class APIBase {
  static const _apiPath = "https://api.openweathermap.org/data/2.5/weather?";
  // static const _apiKEY = "348aa70996626134f7bcc33012f26403";
  static const String _apiKEY = String.fromEnvironment("API_KEY");
  //TODO: check for possible secret to use it on ENV file.

  getApiBase() {
    return _apiPath;
  }

  getAPIKey() {
    return _apiKEY;
  }
}
