class ResponseWrapper<T> {
  final bool isSuccess;
  final bool rateLimitExceeded;
  final String? error;
  final T? data;

  ResponseWrapper(
      this.isSuccess, this.rateLimitExceeded, this.error, this.data);
}