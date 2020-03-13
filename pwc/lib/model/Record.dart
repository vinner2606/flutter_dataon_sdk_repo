import 'package:json_annotation/json_annotation.dart';
import 'package:pwc/model/ErrorResponse.dart';

part 'Record.g.dart';

@JsonSerializable()
class Record {
  @JsonKey()
  ErrorResponse error;
  @JsonKey()
  String primaryKey;
  @JsonKey()
  List<Object> data;


  Record();

  factory Record.fromJson(Map<String, dynamic> json) =>
		  _$RecordFromJson(json);

  Map<String, dynamic> toJson() => _$RecordToJson(this);



}
