class Constants {
  static const String PICSUM_BASE_URL = "https://picsum.photos/v2/list";
  static const String PEXELS_BASE_URL = "https://api.pexels.com/v1";
  static Map<String, String> simpleHeaders() {
    return {
      'content-type': 'application/json',
      'accept': 'application/json',
    };
  }
  static Map<String, String> headers(token) {
    return {
      'content-type': 'application/json',
      'accept': 'application/json',
      'Authorization': token
    };
  }
}