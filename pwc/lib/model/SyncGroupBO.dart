import 'package:json_annotation/json_annotation.dart';
import 'package:pwc/model/ExpandableGroup.dart';
import 'package:pwc/model/SyncTableBO.dart';

part 'SyncGroupBO.g.dart';

@JsonSerializable()
class SyncGroupBO extends ExpandableGroup {
  @JsonKey(name: "sync_type")
  String syncType;
  @JsonKey(name: "last_attemp_timestamp")
  String lastAttempTimestamp;
  @JsonKey(name: "group_id")
  String groupId;
  @JsonKey(name: "is_available_on_ui")
  String isAvailableOnUi;
  @JsonKey(name: "static_process_params")
  String staticProcessParams;
  @JsonKey(name: "base_url")
  String baseUrl;
  @JsonKey(name: "sync_frequency")
  String syncFrequency;
  @JsonKey(name: "recurring_type")
  String recurringType;
  @JsonKey(name: "minimum_battery_threshold")
  String minimumBatteryThreshold;
  @JsonKey(name: "last_attemp_status")
  String lastAttempStatus;
  @JsonKey(name: "is_recurring")
  String isRecurring;
  @JsonKey(name: "schedule_sync_start_timestamp")
  String scheduleSyncStartTimestamp;
  @JsonKey(name: "schedule_sync_stop_timestamp")
  String scheduleSyncStopTimestamp;
  @JsonKey(name: "is_shceduled")
  String isShceduled;
  @JsonKey(name: "group_display_name")
  String groupDisplayName;
  @JsonKey(name: "tables")
  List<SyncTableBO> tables;
  String unSyncedRecordCount;
  String errorRecordCount;

  SyncGroupBO.name(this.groupDisplayName, this.tables)
      : super.name(groupDisplayName, tables);

  SyncGroupBO();
  factory SyncGroupBO.fromJson(Map<String, dynamic> json) =>
      _$SyncGroupBOFromJson(json);

  Map<String, dynamic> toJson() => _$SyncGroupBOToJson(this);
}
