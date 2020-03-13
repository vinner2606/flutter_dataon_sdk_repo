// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SyncTableBO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncTableBO _$SyncTableBOFromJson(Map<String, dynamic> json) {
  return SyncTableBO()
    ..lastSyncRecordsCount = (json['last_sync_records_count']).toInt()
    ..flagOnError = json['flag_on_error'] as String
    ..lastSyncStatus = json['last_sync_status'] as String
    ..lastSyncErrorCount = json['last_sync_error_count'].toInt()
    ..errorRemarksColumn = json['error_remarks_column'] as String
    ..lastSyncSuccessCount = json['last_sync_success_count'].toInt()
    ..lastSyncTimestamp = json['last_sync_timestamp'] as String
    ..recordsSyncTimestampColumnName =
        json['records_sync_timestamp_column_name'] as String
    ..tableSequence = json['table_sequence'].toInt()
    ..syncFlagWhereClause = json['sync_flag_where_clause'] as String
    ..syncFlagColumnName = json['sync_flag_column_name'] as String
    ..processName = json['process_name'] as String
    ..groupId = json['group_id'] as String
    ..errorRemarks = json['error_remarks'] as String
    ..flagOnSuccess = json['flag_on_success'] as String
    ..imageSyncFlagColumnname = json['image_sync_flag_columnname'] as String
    ..mediaFilepathColumnname = json['media_filepath_columnname'] as String
    ..sendLastAttemptServerTimestamp =
        json['send_last_attempt_server_timestamp'] as String
    ..tablename = json['tablename'] as String
    ..primaryKey = json['primary_key'] as String
    ..lastAttemptServerTimestamp =
        json['last_attempt_server_timestamp'] as String
    ..tableSyncStatus = json['table_sync_status'] as String
    ..attemptErrorRemark = json['attemp_error_remarks'] as String
    ..viewName = json['view_name'] as String
    ..unSyncedRecordCount = json['unSyncedRecordCount'] as String
    ..errorRecordCount = json['errorRecordCount'] as String;
}

Map<String, dynamic> _$SyncTableBOToJson(SyncTableBO instance) =>
    <String, dynamic>{
      'last_sync_records_count': instance.lastSyncRecordsCount,
      'flag_on_error': instance.flagOnError,
      'last_sync_status': instance.lastSyncStatus,
      'last_sync_error_count': instance.lastSyncErrorCount,
      'error_remarks_column': instance.errorRemarksColumn,
      'last_sync_success_count': instance.lastSyncSuccessCount,
      'last_sync_timestamp': instance.lastSyncTimestamp,
      'records_sync_timestamp_column_name':
          instance.recordsSyncTimestampColumnName,
      'table_sequence': instance.tableSequence,
      'sync_flag_where_clause': instance.syncFlagWhereClause,
      'sync_flag_column_name': instance.syncFlagColumnName,
      'process_name': instance.processName,
      'group_id': instance.groupId,
      'error_remarks': instance.errorRemarks,
      'flag_on_success': instance.flagOnSuccess,
      'image_sync_flag_columnname': instance.imageSyncFlagColumnname,
      'media_filepath_columnname': instance.mediaFilepathColumnname,
      'send_last_attempt_server_timestamp':
          instance.sendLastAttemptServerTimestamp,
      'tablename': instance.tablename,
      'primary_key': instance.primaryKey,
      'last_attempt_server_timestamp': instance.lastAttemptServerTimestamp,
      'table_sync_status': instance.tableSyncStatus,
      'attemp_error_remarks': instance.attemptErrorRemark,
      'view_name': instance.viewName,
      'unSyncedRecordCount': instance.unSyncedRecordCount,
      'errorRecordCount': instance.errorRecordCount
    };
