import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
abstract class PWConListener<T, U, V> {
  onCompleted(T t, U u);

  onIOExceptionOccured(V v);
}
