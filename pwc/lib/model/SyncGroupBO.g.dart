// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SyncGroupBO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncGroupBO _$SyncGroupBOFromJson(Map<String, dynamic> json) {
  return SyncGroupBO()
    ..title = json['title'] as String
    ..syncType = json['sync_type'] as String
    ..lastAttempTimestamp = json['last_attemp_timestamp'] as String
    ..groupId = json['group_id'] as String
    ..isAvailableOnUi = json['is_available_on_ui'] as String
    ..staticProcessParams = json['static_process_params'] as String
    ..baseUrl = json['base_url'] as String
    ..syncFrequency = json['sync_frequency'] as String
    ..recurringType = json['recurring_type'] as String
    ..minimumBatteryThreshold = json['minimum_battery_threshold'] as String
    ..lastAttempStatus = json['last_attemp_status'] as String
    ..isRecurring = json['is_recurring'] as String
    ..scheduleSyncStartTimestamp =
        json['schedule_sync_start_timestamp'] as String
    ..scheduleSyncStopTimestamp = json['schedule_sync_stop_timestamp'] as String
    ..isShceduled = json['is_shceduled'] as String
    ..groupDisplayName = json['group_display_name'] as String
    ..tables = (json['tables'] as List)
        ?.map((e) =>
            e == null ? null : SyncTableBO.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..unSyncedRecordCount = json['unSyncedRecordCount'] as String
    ..errorRecordCount = json['errorRecordCount'] as String;
}

Map<String, dynamic> _$SyncGroupBOToJson(SyncGroupBO instance) =>
    <String, dynamic>{
      'title': instance.title,
      'sync_type': instance.syncType,
      'last_attemp_timestamp': instance.lastAttempTimestamp,
      'group_id': instance.groupId,
      'is_available_on_ui': instance.isAvailableOnUi,
      'static_process_params': instance.staticProcessParams,
      'base_url': instance.baseUrl,
      'sync_frequency': instance.syncFrequency,
      'recurring_type': instance.recurringType,
      'minimum_battery_threshold': instance.minimumBatteryThreshold,
      'last_attemp_status': instance.lastAttempStatus,
      'is_recurring': instance.isRecurring,
      'schedule_sync_start_timestamp': instance.scheduleSyncStartTimestamp,
      'schedule_sync_stop_timestamp': instance.scheduleSyncStopTimestamp,
      'is_shceduled': instance.isShceduled,
      'group_display_name': instance.groupDisplayName,
      'tables': instance.tables,
      'unSyncedRecordCount': instance.unSyncedRecordCount,
      'errorRecordCount': instance.errorRecordCount
    };
