import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:battery/battery.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pwc/datastore/DAO.dart';
import 'package:pwc/internal/core/CorePlatware.dart';
import 'package:pwc/model/FilePersistor.dart';
import 'package:pwc/model/PlatwarePropertyModel.dart';
import 'package:pwc/model/SyncGroupBO.dart';
import 'package:pwc/model/SyncTableBO.dart';
import 'package:pwc/model/enums.dart';
import 'package:pwc/security/Encryption.dart';
import 'package:pwc/security/EncryptionFactory.dart';
import 'package:pwc/sync/SyncApi.dart';
import 'package:pwc/utility/Constants.dart';
import 'package:pwc/utility/LocationManager.dart';
import 'package:pwc/utility/Utility.dart';

class PWCUtils {
  static final PWCUtils _singleton = new PWCUtils._internal();

  factory PWCUtils() => _singleton;
  PlatwareProperties _mPlatwareProperties;

  PlatwareProperties get mPlatwareProperties {
    return _mPlatwareProperties;
  }

  Future<PlatwareProperties> getUpdatedPlatwareProperty() async {
    _mPlatwareProperties =
        await mFilePersistor?.getPlatwarePropertiesFromFile();
    return _mPlatwareProperties;
  }

  set mPlatwareProperties(PlatwareProperties mPlatwareProperties) {
    if (mPlatwareProperties == null) {
      return;
    }
    _mPlatwareProperties = mPlatwareProperties;
  }

  FilePersistor mFilePersistor;
  List<Object> mPropertyJsonArray;

  Map<String, Object> mPropertyPair = new Map();
  List<Object> mSynConfig;
  List<SyncGroupBO> mSyncGroupBO = new List();
  String _applicationVersion;
  Encryption encryptionUtil =
      EncryptionFactory.getEncryption(EncryptionType.AES);
  var batteryStatus;
  var charging = false;
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  LocationManager locationManager = LocationManager();

  PWCUtils._internal() {
//    getAllParamsFromFile();
//    isPhonePluggedIn();
  }

  void getAllParamsFromFile() async {
    try {
      //   startTimerForInternetConnection();
      mFilePersistor = FilePersistor();
      PlatwareProperties temp =
          await mFilePersistor?.getPlatwarePropertiesFromFile();

      if (mFilePersistor == null) {
        return;
      }
      if (temp != null) {
        _mPlatwareProperties = temp;
      }

      if (await mFilePersistor
          .isFilePresent(Constants.PROPERTY_MASTER_FILE_NAME)) {
        String data =
            await mFilePersistor.readFile(Constants.PROPERTY_MASTER_FILE_NAME);
        if (data != null && data.isNotEmpty) {
          mPropertyJsonArray = json.decode(data);
        }
      }

      if (await mFilePersistor.isFilePresent(Constants.PWSYNCCONFIG_FILENAME)) {
        String data =
            await mFilePersistor.readFile(Constants.PWSYNCCONFIG_FILENAME);
        if (data != null && data.isNotEmpty) {
          mSynConfig = json.decode(data);
          if (mSynConfig != null) {
            processSyncGroupBO(mSynConfig);
          }
        }
      }
    } catch (ex, stacktrace) {
      print(stacktrace);
    }
  }

  String get applicationVersion {
    if (_applicationVersion == null) {
      _applicationVersion = CorePlatware().applicationVersion;
    }
    return _applicationVersion;
  }

  String _decryptedSecret;

  Future<String> getDecryptedSecret() async {
    if (_decryptedSecret == null) {
      PWcData pWcData = await mFilePersistor.getPwcDataFromFile();
      _decryptedSecret = pWcData?.appSecret;
      if (_decryptedSecret == null) {
        _decryptedSecret = mPlatwareProperties?.initParams?.appSecret;
      }
    }
    return _decryptedSecret;
  }

  String _loginId;

  Future<String> getLoginId() async {
    if (_loginId == null) {
      PlatwareProperties platwareProperties =
          await mFilePersistor?.getPlatwarePropertiesFromFile();
      _loginId = platwareProperties.loginId;
    }
    return _loginId;
  }

  set loginId(String loginId) {
    this._loginId = loginId;
  }

  String _decryptedKey;

  String get decryptedKey {
    if (_decryptedKey == null) {
      if (mPlatwareProperties?.key != null) {
        _decryptedKey = mPlatwareProperties?.key;
      } else {
        _decryptedKey = requestId;
        mPlatwareProperties?.key = _decryptedKey;
//
      }
    }

    return _decryptedKey;
  }

  String _decryptedToken;

  Future<String> getDecryptedToken() async {
    if (_decryptedToken == null) {
      PlatwareProperties platwareProperties =
          await mFilePersistor?.getPlatwarePropertiesFromFile();
      if (platwareProperties != null && platwareProperties.token != null) {
        _decryptedToken = platwareProperties.token;
      }
    }
    return _decryptedToken;
  }

  set decryptedToken(String decryptedToken) {
    this._decryptedToken = decryptedToken;
  }

  String _registrationId;

  Future<String> get decryptedRegistrationId async {
    if (_registrationId == null) {
      PlatwareProperties platwareProperties =
          await mFilePersistor?.getPlatwarePropertiesFromFile();
      _registrationId = platwareProperties.registrationId;
      /*if (decryptedKey != null && registrationId != null) {
        _registrationId =
            await encryptionUtil.decrypt(decryptedKey, registrationId);
      } else {
        _registrationId = registrationId;
      }*/
    }
    return _registrationId;
  }

  set registrationId(String val) {
    this._registrationId = val;
  }

  String get requestId {
    StringBuffer sequenceNumber = StringBuffer();
    sequenceNumber.write(DateTime.now().millisecondsSinceEpoch);
    if (sequenceNumber.length < 16) {
      sequenceNumber.write(DateTime.now().millisecondsSinceEpoch);
    }
    return sequenceNumber
        .toString()
        .substring(sequenceNumber.toString().length - 16);
  }

  DeviceDetails get deviceDetails {
    return CorePlatware().deviceDetails;
  }

  Future<int> get batteryLevel async {
    var battery = Battery();
    return await battery.batteryLevel;
  }

  /*void startTimerForInternetConnection() {
    Timer.periodic(new Duration(seconds: 1), (Timer timer) async {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        isInternetConnected = true;
      } else if (connectivityResult == ConnectivityResult.wifi) {
        isInternetConnected = true;
      } else {
        isInternetConnected = false;
      }
    });
  }*/

  bool isInternetConnected = true;

  bool _isConfigurationChanged = false;

  bool get isConfigurationChanged {
    return _isConfigurationChanged;
  }

  set isConfigurationChanged(bool updated) {
    if (!_isConfigurationChanged && updated) {
      loadAllConfigurations();
      _decryptedToken = null;
      _registrationId = null;
      isConfigurationChanged = false;
    }
  }

  bool isAllConfigurationFileAvailable(InitParams initParam) =>
      initParam.isBackgroundSyncEnabled && mSynConfig != null;

  loadAllConfigurations() async {
    try {
      PlatwareProperties temp =
          await mFilePersistor?.getPlatwarePropertiesFromFile();

      if (temp != null || temp.initParams != null) {
        _mPlatwareProperties = temp;
      }
      String object =
          await mFilePersistor.readFile(Constants.PROPERTY_MASTER_FILE_NAME);
      if (object != null && object is List) {
        mPropertyJsonArray = json.decode(object);
      }

      if (mPlatwareProperties?.initParams?.isBackgroundSyncEnabled == true) {
        var data =
            await mFilePersistor.readFile(Constants.PWSYNCCONFIG_FILENAME);
        if (data != null) {
          mSynConfig = await json.decode(data);
        }
        if (mSynConfig != null) {
          processSyncGroupBO(mSynConfig);
        }
      }

      loadPropertyMaster();
    } catch (e, stacktrace) {
      //  print(stacktrace);
    }
  }

  processSyncGroupBO(List<Object> list) {
    if (list != null && list.length > 0) {
      mSyncGroupBO.clear();
    }
    list.forEach((obj) {
      try {
        mSyncGroupBO.add(SyncGroupBO.fromJson(obj));
      } catch (ex, stacktrace) {
        print(stacktrace);
      }
    });
  }

  String getProperty(String key) {
    if (mPropertyPair != null) {
      return mPropertyPair[key] ?? "";
    }
    return "";
  }

  DAO getDao() {
    if (mPlatwareProperties != null &&
        !Utility.isEmpty(mPlatwareProperties?.initParams?.databaseName)) {
      return CorePlatware().getDatabaseAccessObject;
    } else {
      return null;
    }
  }

  /**
	 * update configuration of table when successfully sync data with server
	 */
  void updateTableConfigOnSuccess(
      SyncTableBO syncTableBO, int recordCount, String lastserTime) {
    syncTableBO.lastSyncStatus = syncTableBO.flagOnSuccess;
    syncTableBO.tableSyncStatus = "S";
    syncTableBO.lastSyncSuccessCount = syncTableBO.lastSyncSuccessCount + 1;
    syncTableBO.lastSyncTimestamp = Utility.currentFormattedTimestamp();
    syncTableBO.lastSyncRecordsCount = recordCount;
    syncTableBO.lastAttemptServerTimestamp = lastserTime;
    saveSyncConfiguration();
  }

  void saveSyncConfiguration() async {
    try {
      mFilePersistor.writeFile(
          Constants.PWSYNCCONFIG_FILENAME, jsonEncode(mSyncGroupBO));
    } catch (e, stacktrace) {
      print(stacktrace);
    }
  }

  /**
	 * update configuration of table when some error occured
	 * in sync
	 */
  void updateTableConfigOnError(SyncTableBO syncTableBO, String errorRemarks) {
    syncTableBO.lastSyncStatus = syncTableBO.flagOnError;
    syncTableBO.tableSyncStatus = "F";
    syncTableBO.attemptErrorRemark = errorRemarks;
    syncTableBO.lastSyncErrorCount = syncTableBO.lastSyncErrorCount + 1;
    saveSyncConfiguration();
  }

  static String pwSessionID() {
    var buffer = new StringBuffer();
    buffer.write(Utility.currentFormattedTimestamp(
        dateFormat: DateTimeFormat.YY_MM_DD_HH_MM_SS_SSS));
    var randomnumer =
        (Random().nextDouble() * 10000000000000000).round().toString();
    var length = randomnumer.length;
    if (length < 17) {
      for (var i = 0; i < 17 - length; i++) {
        buffer.write("0");
      }
    }
    buffer.write(randomnumer);
    return buffer.toString();
  }

  void loadPropertyMaster() {
    if (mPropertyJsonArray != null && mPropertyJsonArray.length > 0) {
      mPropertyPair = Map();
      mPropertyJsonArray.forEach((obj) {
        Map<String, Object> valueMap = json.decode(obj);
        mPropertyPair["propertyName"] = valueMap["propertyValue"];
      });
    }
  }

  void isPhonePluggedIn() {
    var battery = Battery();
    print(battery.batteryLevel);
    battery.onBatteryStateChanged
      ..listen((BatteryState state) {
        if (state == BatteryState.charging) {
          batteryStatus = state;
          charging = true;
        } else if (state == BatteryState.discharging) {
          batteryStatus = state;
          charging = false;
        } else if (state == BatteryState.full) {
          batteryStatus = state;
        }
      });
  }

  void scheduleJobForNotification() async {
    try {
      callback() async {
        try {
          var totalUnsyncedRecords = 0;
          var pwcUtils = PWCUtils();
          var dao = pwcUtils.getDao();
          var unsyncProcessList = List<String>();
          pwcUtils.mSyncGroupBO.forEach((obj) async {
            if (obj.groupId.toLowerCase() == SyncApi.TYPE_SYNC_OUTBOUND) {
              obj.tables.forEach((syncTableBO) async {
                var unSyncedRecords = await dao.getUnSyncedRecordCount(
                    syncTableBO.tablename, syncTableBO.syncFlagWhereClause);
                if (unSyncedRecords > 0) {
                  unsyncProcessList.add(syncTableBO.processName);
                  totalUnsyncedRecords += unSyncedRecords;
                }
              });
            }
          });

          if (unsyncProcessList.length > 0) {
            if (Utility.isAppIsInBackground()) {
              pwcUtils._showNotification(
                  unsyncProcessList, totalUnsyncedRecords);
            }
          }
        } catch (ex, stacktrace) {
          print(stacktrace);
        }
      }

      Duration duration = Duration(milliseconds: 60 * 60 * 1000);
      await AndroidAlarmManager.initialize();
      await AndroidAlarmManager.periodic(
          duration, Constants.PWSYNC_REQUEST_CODE, callback);
    } catch (ex) {
      print(ex);
    }
  }

  Future _showNotification(
      List<String> listUnSyncedProcess, int totalUnSyncRecords) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, 'Syncing', '', platformChannelSpecifics, payload: 'item x');
  }
}
