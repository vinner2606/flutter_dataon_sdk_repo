// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Response _$ResponseFromJson(Map<String, dynamic> json) {
  return Response()
    ..serviceName = json['serviceName']
    ..responseHandleType = json['responseHandleType'] as String
    ..whereCondition = json['whereCondition'] as String
    ..responseHandleBy = json['responseHandleBy'] as String
    ..tableName = json['tableName'] as String
    ..error = json['error'] == null
        ? null
        : ErrorResponse.fromJson(json['error'] as Map<String, dynamic>)
    ..records = (json['records'] as List)
        ?.map((e) =>
            e == null ? null : Record.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
      'serviceName': instance.serviceName,
      'responseHandleType': instance.responseHandleType,
      'whereCondition': instance.whereCondition,
      'responseHandleBy': instance.responseHandleBy,
      'tableName': instance.tableName,
      'error': instance.error,
      'records': instance.records
    };
