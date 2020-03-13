import 'package:json_annotation/json_annotation.dart';
import 'package:pwc/model/ErrorResponse.dart';
import 'package:pwc/model/Record.dart';

part 'Response.g.dart';

@JsonSerializable()
class Response {
  @JsonKey()
  var serviceName;

  Response();

  Response.name(this.serviceName);

  @JsonKey()
  String responseHandleType;
  @JsonKey()
  String whereCondition;
  @JsonKey()
  String responseHandleBy;
  @JsonKey()
  String tableName;
  @JsonKey()
  ErrorResponse error;
  @JsonKey()
  List<Record> records;

  List<Map> getNotNullData() {
    List<List> dataArray = new List();
    records.forEach((r) {
      if (r.error == null && r.data != null) {
        dataArray.add(r.data);
      }
    });
    return getListFromJson(dataArray);
  }

  List<Map<Object, Object>> getListFromJson(List<List> dataArray) {
    List<Map<Object, Object>> list = new List();
    if (dataArray == null) {
      return list;
    }
    dataArray.forEach((item) {
      if (item != null) {
        item.asMap().forEach((k, v) {
          if (v is Map) {
            list.add(v);
          }
        });
      }
    });
    return list;
  }

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}
