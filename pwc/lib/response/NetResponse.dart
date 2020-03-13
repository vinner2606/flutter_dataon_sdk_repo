import 'package:json_annotation/json_annotation.dart';
part 'NetResponse.g.dart';

@JsonSerializable()
class NetResponse {
  String data;
  Map<String, Object> header;
  int statusCode;


  NetResponse();

  factory NetResponse.fromJson(Map<String, dynamic> json) =>
          _$NetResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NetResponseToJson(this);


}
