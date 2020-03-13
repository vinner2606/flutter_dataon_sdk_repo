// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NetResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetResponse _$NetResponseFromJson(Map<String, dynamic> json) {
  return NetResponse()
    ..data = json['data'] as String
    ..header = json['header'] as Map<String, dynamic>
    ..statusCode = json['statusCode'] as int;
}

Map<String, dynamic> _$NetResponseToJson(NetResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'header': instance.header,
      'statusCode': instance.statusCode
    };
