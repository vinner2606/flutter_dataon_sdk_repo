// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'RecordSyncBO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordSyncBO _$RecordSyncBOFromJson(Map<String, dynamic> json) {
  return RecordSyncBO()
    ..tableName = json['TABLENAME'] as String
    ..primaryKeyValue = json['PRIMARY_KEY_VALUE'] as String
    ..primaryKeyColumnName = json['PRIMARY_KEY_COLUMN_NAME'] as String
    ..lastSyncTimestamp = json['LAST_SYNC_TIMESTAMP'] as String
    ..syncFlagValue = json['ISSUCCESSFUL'] as String
    ..errorRemarks = json['ERROR_REMARKS'] as String
    ..syncFlagColumnName = json['sync_flag_column_name'] as String
    ..syncTimeStampColumnName =
        json['records_sync_timestamp_column_name'] as String
    ..errorRemarksColumnName = json['error_remarks_column'] as String
    ..action = json['ACTION'] as String
    ..actionQuery = json['QUERY'] as String;
}

Map<String, dynamic> _$RecordSyncBOToJson(RecordSyncBO instance) =>
    <String, dynamic>{
      'TABLENAME': instance.tableName,
      'PRIMARY_KEY_VALUE': instance.primaryKeyValue,
      'PRIMARY_KEY_COLUMN_NAME': instance.primaryKeyColumnName,
      'LAST_SYNC_TIMESTAMP': instance.lastSyncTimestamp,
      'ISSUCCESSFUL': instance.syncFlagValue,
      'ERROR_REMARKS': instance.errorRemarks,
      'sync_flag_column_name': instance.syncFlagColumnName,
      'records_sync_timestamp_column_name': instance.syncTimeStampColumnName,
      'error_remarks_column': instance.errorRemarksColumnName,
      'ACTION': instance.action,
      'QUERY': instance.actionQuery
    };
