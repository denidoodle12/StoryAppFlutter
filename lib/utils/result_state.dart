sealed class ResultState<T> {
  const ResultState();
}

class ResultLoading<T> extends ResultState<T> {
  const ResultLoading();
}

class ResultSuccess<T> extends ResultState<T> {
  final T data;
  const ResultSuccess(this.data);
}

class ResultError<T> extends ResultState<T> {
  final String message;
  const ResultError(this.message);
}

class ResultEmpty<T> extends ResultState<T> {
  const ResultEmpty();
}
