import 'package:json_annotation/json_annotation.dart';

part 'SyncTableBO.g.dart';

@JsonSerializable()
class SyncTableBO {
  @JsonKey(name: "last_sync_records_count")
  int lastSyncRecordsCount;
  @JsonKey(name: "flag_on_error")
  String flagOnError;
  @JsonKey(name: "last_sync_status")
  String lastSyncStatus;
  @JsonKey(name: "last_sync_error_count")
  int lastSyncErrorCount;
  @JsonKey(name: "error_remarks_column")
  String errorRemarksColumn;
  @JsonKey(name: "last_sync_success_count")
  int lastSyncSuccessCount;
  @JsonKey(name: "last_sync_timestamp")
  String lastSyncTimestamp;
  @JsonKey(name: "records_sync_timestamp_column_name")
  String recordsSyncTimestampColumnName;
  @JsonKey(name: "table_sequence")
  int tableSequence;
  @JsonKey(name: "sync_flag_where_clause")
  String syncFlagWhereClause;
  @JsonKey(name: "sync_flag_column_name")
  String syncFlagColumnName;
  @JsonKey(name: "process_name")
  String processName;
  @JsonKey(name: "group_id")
  String groupId;
  @JsonKey(name: "error_remarks")
  String errorRemarks;
  @JsonKey(name: "flag_on_success")
  String flagOnSuccess;
  @JsonKey(name: "image_sync_flag_columnname")
  String imageSyncFlagColumnname;
  @JsonKey(name: "media_filepath_columnname")
  String mediaFilepathColumnname;
  @JsonKey(name: "send_last_attempt_server_timestamp")
  String sendLastAttemptServerTimestamp;
  String tablename;
  @JsonKey(name: "primary_key")
  String primaryKey;
  @JsonKey(name: "last_attempt_server_timestamp")
  String lastAttemptServerTimestamp;
  @JsonKey(name: "table_sync_status")
  String tableSyncStatus;
  @JsonKey(name: "attemp_error_remarks")
  String attemptErrorRemark;
  @JsonKey(name: "view_name")
  @JsonKey(name: "record_sync_limit")
  int recordSyncLimit;
  String viewName;
  String unSyncedRecordCount;
  String errorRecordCount;

  SyncTableBO();

  factory SyncTableBO.fromJson(Map<String, dynamic> json) =>
      _$SyncTableBOFromJson(json);

  Map<String, dynamic> toJson() => _$SyncTableBOToJson(this);
}
