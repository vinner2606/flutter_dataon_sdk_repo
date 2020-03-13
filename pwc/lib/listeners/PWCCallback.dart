abstract class PWCCallback<T> {
  onFailure(String message, {String code});
  onResponse(T t);
}
