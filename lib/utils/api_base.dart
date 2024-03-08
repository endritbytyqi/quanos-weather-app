class APIBase {
  static const _apiPath = "https://api.openweathermap.org/data/2.5/weather?q=";
  static const _apiKEY = "348aa70996626134f7bcc33012f26403";
  //TODO: check for possible secret to use it on ENV file.

  getApiBase() {
    return _apiPath;
  }

  getAPIKey() {
    return _apiKEY;
  }
}
