// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PlatwarePropertyModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlatwareProperties _$PlatwarePropertiesFromJson(Map<String, dynamic> json) {
  return PlatwareProperties()
    ..deviceDetails = json['deviceDetails'] == null
        ? null
        : DeviceDetails.fromJson(json['deviceDetails'] as Map<String, dynamic>)
    ..initParams = json['initParams'] == null
        ? null
        : InitParams.fromJson(json['initParams'] as Map<String, dynamic>)
    ..registrationId = json['registrationId'] as String
    ..exponent = json['exponent'] as String
    ..modulus = json['modulus'] as String
    ..token = json['token'] as String
    ..installationTimeStamp = json['installationTimeStamp'] as String
    ..platform = json['platform'] as String
    ..pwClientVersion = json['pwClientVersion'] as String
    ..platwareVersion = json['platwareVersion'] as String
    ..platwareConfigVersion = json['platwareConfigVersion'] as String
    ..isSessionExpired = json['isSessionExpired'] as bool
    ..loginId = json['loginId'] as String
    ..key = json['key'] as String;
}

Map<String, dynamic> _$PlatwarePropertiesToJson(PlatwareProperties instance) =>
    <String, dynamic>{
      'deviceDetails': instance.deviceDetails,
      'initParams': instance.initParams,
      'registrationId': instance.registrationId,
      'exponent': instance.exponent,
      'modulus': instance.modulus,
      'token': instance.token,
      'installationTimeStamp': instance.installationTimeStamp,
      'platform': instance.platform,
      'pwClientVersion': instance.pwClientVersion,
      'platwareVersion': instance.platwareVersion,
      'platwareConfigVersion': instance.platwareConfigVersion,
      'isSessionExpired': instance.isSessionExpired,
      'loginId': instance.loginId,
      'key': instance.key
    };

DeviceDetails _$DeviceDetailsFromJson(Map<String, dynamic> json) {
  return DeviceDetails()
    ..imeiNumber = json['imeiNumber'] as String
    ..simId = json['simId'] as String
    ..deviceModel = json['deviceModel'] as String
    ..deviceMake = json['deviceMake'] as String
    ..androidVersion = json['androidVersion'] as String;
}

Map<String, dynamic> _$DeviceDetailsToJson(DeviceDetails instance) =>
    <String, dynamic>{
      'imeiNumber': instance.imeiNumber,
      'simId': instance.simId,
      'deviceModel': instance.deviceModel,
      'deviceMake': instance.deviceMake,
      'androidVersion': instance.androidVersion
    };

InitParams _$InitParamsFromJson(Map<String, dynamic> json) {
  return InitParams()
    ..isBackgroundSyncEnabled = json['isBackgroundSyncEnabled'] as bool
    ..isRootedDeviceAllowed = json['isRootedDeviceAllowed'] as bool
    ..isBypassCheckSum = json['isBypassCheckSum'] as bool
    ..isSSLByPassRequired = json['isSSLByPassRequired'] as bool
    ..requestTimeout = json['requestTimeout'] as num
    ..orgId = json['orgId'] as String
    ..appId = json['appId'] as String
    ..appSecret = json['appSecret'] as String
    ..platwareUrl = json['platwareUrl'] as String
    ..databaseName = json['databaseName']
    ..autoSyncDuration = json['autoSyncDuration'] as num;
}

Map<String, dynamic> _$InitParamsToJson(InitParams instance) =>
    <String, dynamic>{
      'isBackgroundSyncEnabled': instance.isBackgroundSyncEnabled,
      'isRootedDeviceAllowed': instance.isRootedDeviceAllowed,
      'isBypassCheckSum': instance.isBypassCheckSum,
      'isSSLByPassRequired': instance.isSSLByPassRequired,
      'requestTimeout': instance.requestTimeout,
      'orgId': instance.orgId,
      'appId': instance.appId,
      'appSecret': instance.appSecret,
      'platwareUrl': instance.platwareUrl,
      'databaseName': instance.databaseName,
      'autoSyncDuration': instance.autoSyncDuration
    };

PWcData _$PWcDataFromJson(Map<String, dynamic> json) {
  return PWcData(json['appSecret'] as String);
}

Map<String, dynamic> _$PWcDataToJson(PWcData instance) =>
    <String, dynamic>{'appSecret': instance.appSecret};
