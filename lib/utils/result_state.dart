sealed class ResultState<T> {
  const ResultState();
}

final class ResultLoading<T> extends ResultState<T> {
  const ResultLoading();
}

final class ResultSuccess<T> extends ResultState<T> {
  final T data;
  const ResultSuccess(this.data);
}

final class ResultError<T> extends ResultState<T> {
  final String message;
  const ResultError(this.message);
}

final class ResultEmpty<T> extends ResultState<T> {
  const ResultEmpty();
}
