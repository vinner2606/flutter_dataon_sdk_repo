
import 'package:json_annotation/json_annotation.dart';
part 'RecordSyncBO.g.dart';

@JsonSerializable()
class RecordSyncBO{
  @JsonKey(name: "TABLENAME")
  String tableName;
  @JsonKey(name: "PRIMARY_KEY_VALUE")
  String primaryKeyValue;
  @JsonKey(name: "PRIMARY_KEY_COLUMN_NAME")
  String primaryKeyColumnName;
  @JsonKey(name: "LAST_SYNC_TIMESTAMP")
  String lastSyncTimestamp;
  @JsonKey(name: "ISSUCCESSFUL")
  String syncFlagValue;
  @JsonKey(name: "ERROR_REMARKS")
  String errorRemarks;
  @JsonKey(name: "sync_flag_column_name")
  String syncFlagColumnName;
  @JsonKey(name: "records_sync_timestamp_column_name")
  String syncTimeStampColumnName;
  @JsonKey(name: "error_remarks_column")
  String errorRemarksColumnName;
  @JsonKey(name: "ACTION")
  String action;
  @JsonKey(name: "QUERY")
  String actionQuery;

  RecordSyncBO();

  factory RecordSyncBO.fromJson(Map<String, dynamic> json) =>
      _$RecordSyncBOFromJson(json);

  Map<String, dynamic> toJson() => _$RecordSyncBOToJson(this);


}