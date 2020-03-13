// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Record _$RecordFromJson(Map<String, dynamic> json) {
  return Record()
    ..error = json['error'] == null
        ? null
        : ErrorResponse.fromJson(json['error'] as Map<String, dynamic>)
    ..primaryKey = json['primaryKey'] as String
    ..data = json['data'] as List;
}

Map<String, dynamic> _$RecordToJson(Record instance) => <String, dynamic>{
      'error': instance.error,
      'primaryKey': instance.primaryKey,
      'data': instance.data
    };
