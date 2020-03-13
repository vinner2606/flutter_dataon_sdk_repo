import 'package:json_annotation/json_annotation.dart';
import 'package:pwc/utility/Utility.dart';

part 'PlatwarePropertyModel.g.dart';

@JsonSerializable()
class PlatwareProperties {
  @JsonKey()
  DeviceDetails deviceDetails;
  @JsonKey()
  InitParams initParams;
  @JsonKey()
  String registrationId;
  @JsonKey()
  String exponent;
  @JsonKey()
  String modulus;
  @JsonKey()
  String token;
  @JsonKey()
  String installationTimeStamp;
  @JsonKey()
  String platform = "ANDROID";
  @JsonKey()
  String pwClientVersion;
  @JsonKey()
  String platwareVersion = "2.0";
  @JsonKey()
  String platwareConfigVersion = "1.0";
  // @JsonKey()
  bool isSessionExpired = false;
  @JsonKey()
  String loginId;
  @JsonKey()
  String key;
  @JsonKey()
  bool isSyncConfigurationLoaded;

  PlatwareProperties();

  factory PlatwareProperties.fromJson(Map<String, dynamic> json) =>
      _$PlatwarePropertiesFromJson(json);

  Map<String, dynamic> toJson() => _$PlatwarePropertiesToJson(this);
}

@JsonSerializable()
class DeviceDetails {
  @JsonKey()
  String imeiNumber;
  @JsonKey()
  String simId;
  @JsonKey()
  String deviceModel;
  @JsonKey()
  String deviceMake;
  @JsonKey()
  String androidVersion;

  DeviceDetails();

  factory DeviceDetails.fromJson(Map<String, dynamic> json) =>
      _$DeviceDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceDetailsToJson(this);
}

@JsonSerializable()
class InitParams {
  //@JsonKey()
  bool isBackgroundSyncEnabled = false;
  //@JsonKey()
  bool isRootedDeviceAllowed = false;
  //@JsonKey()
  bool isBypassCheckSum = false;
  //@JsonKey()
  bool isSSLByPassRequired = false;
  @JsonKey()
  num requestTimeout = 60000;

  @JsonKey()
  String orgId;

  @JsonKey()
  String appId;

  @JsonKey()
  String appSecret;

  String platwareUrl;

  InitParams();

  InitParams.name(this.orgId, this.appId, this.appSecret, this.platwareUrl) {
    if (null == orgId) {
      throw Exception("Org id is not valid");
    }
    if (null == appId) {
      throw Exception("App id is not valid");
    }
    if (null == appSecret || appSecret == "") {
      throw Exception("App appSecret is not valid");
    }
    if (null == platwareUrl) {
      throw Exception("Illegal Url");
    }
  }

  String _databaseName;
  get databaseName => _databaseName;

  set databaseName(value) {
    if (null == value) {
      throw Exception("Illegal Database Name");
    }
    _databaseName = value;
  }

  @JsonKey()
  num _autoSyncDuration = 30;

  num get autoSyncDuration => _autoSyncDuration;

  set autoSyncDuration(num value) {
    if (value != 0 && value < 30) {
      throw Exception("Sync Duration can't be less that 30");
    }
    _autoSyncDuration = value;
  }

  set(value) {
    if (value != null && value.isEmpty()) {
      throw Exception("SSL Certificate path must be valid");
    }
    _sslCertificatePath = value;
  }


  List<String> _sslCertificatePath;

  List<String> get sslCertificatePath => _sslCertificatePath;

  set sslCertificatePath(List<String> value) {
    if (value != null /*&& value.isEmpty()*/) {
      value.forEach((path){
        if(path!=null && path.isEmpty){
          throw Exception("SSL Certificate path must be valid");
        }
      });

    }
    _sslCertificatePath = value;
  }


  factory InitParams.fromJson(Map<String, dynamic> json) =>
      _$InitParamsFromJson(json);

  Map<String, dynamic> toJson() => _$InitParamsToJson(this);
}

@JsonSerializable()
class PWcData {
  @JsonKey()
  String appSecret;

  PWcData(this.appSecret);

  factory PWcData.fromJson(Map<String, dynamic> json) =>
      _$PWcDataFromJson(json);

  Map<String, dynamic> toJson() => _$PWcDataToJson(this);
}
