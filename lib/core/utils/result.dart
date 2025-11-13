import 'package:catch_table/core/errors/failures.dart';

/// Either 패턴을 구현한 Result 타입
///
/// Repository에서 반환하는 값의 타입으로 사용
/// Success 또는 Failure를 담을 수 있음
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

class Error<T> extends Result<T> {
  const Error(this.failure);

  final Failure failure;
}

/// Result 확장 메서드
extension ResultExtension<T> on Result<T> {
  /// Success일 때 값을 반환하고, Error일 때는 null을 반환
  T? get valueOrNull {
    return switch (this) {
      Success(value: final value) => value,
      Error() => null,
    };
  }

  /// Error일 때 Failure를 반환하고, Success일 때는 null을 반환
  Failure? get failureOrNull {
    return switch (this) {
      Success() => null,
      Error(failure: final failure) => failure,
    };
  }

  /// Success 여부 확인
  bool get isSuccess => this is Success<T>;

  /// Error 여부 확인
  bool get isError => this is Error<T>;

  /// map: Success일 때만 변환 함수 적용
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(value: final value) => Success(transform(value)),
      Error(failure: final failure) => Error(failure),
    };
  }

  /// flatMap: Success일 때 변환 함수를 적용하고 Result를 반환
  Result<R> flatMap<R>(Result<R> Function(T value) transform) {
    return switch (this) {
      Success(value: final value) => transform(value),
      Error(failure: final failure) => Error(failure),
    };
  }

  /// fold: Success와 Error 각각에 대해 함수를 적용
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    return switch (this) {
      Success(value: final value) => onSuccess(value),
      Error(failure: final failure) => onError(failure),
    };
  }
}
