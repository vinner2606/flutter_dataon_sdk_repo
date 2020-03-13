import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'ErrorResponse.g.dart';

@JsonSerializable()
class ErrorResponse {
  @JsonKey(name: "code")
  var code;
  @JsonKey(name: "type")
  var type;
  @JsonKey(name: "message")
  var message;
  @JsonKey(name: "details")
  var details;

  ErrorResponse();


  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);



}
