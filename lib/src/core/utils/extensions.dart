extension FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension FirstWhereOrNullAsync<T> on Iterable<T> {
  Future<T?> firstWhereOrNullAsync(
    Future<bool> Function(T element) test,
  ) async {
    for (final element in this) {
      if (await test(element)) return element;
    }
    return null;
  }
}

extension NullOrEmptyExtension on Object? {
  bool get isNullOrEmpty {
    if (this == null) return true;
    if (this is String) return (this as String).trim().isEmpty;
    if (this is Iterable) return (this as Iterable).isEmpty;
    if (this is Map) return (this as Map).isEmpty;
    return false;
  }
}
