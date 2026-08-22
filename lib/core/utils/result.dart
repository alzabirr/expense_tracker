/// Sealed Result type for error propagation across layer boundaries.
/// No exceptions are thrown across domain/data/presentation layers.
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error, {this.stackTrace});
  final AppFailure error;
  final StackTrace? stackTrace;
}

extension ResultX<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T get data => (this as Success<T>).data;
  AppFailure get error => (this as Failure<T>).error;

  R when<R>({
    required R Function(T data) success,
    required R Function(AppFailure error) failure,
  }) {
    return switch (this) {
      Success<T> s => success(s.data),
      Failure<T> f => failure(f.error),
    };
  }

  Result<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success<T> s => Success(mapper(s.data)),
      Failure<T> f => Failure<R>(f.error, stackTrace: f.stackTrace),
    };
  }
}

/// Domain failure types.
sealed class AppFailure {
  const AppFailure(this.message);
  final String message;
}

final class DatabaseFailure extends AppFailure {
  const DatabaseFailure(super.message);
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message);
}

final class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message);
}
