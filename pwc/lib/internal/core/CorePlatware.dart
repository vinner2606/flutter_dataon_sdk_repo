import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pwc/datastore/DAO.dart';
import 'package:pwc/datastore/SQLiteDAO.dart';
import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/model/FilePersistor.dart';
import 'package:pwc/model/PlatwarePropertyModel.dart';
import 'package:pwc/utility/Utility.dart';

class CorePlatware {
  static final CorePlatware _singleton = new CorePlatware._internal();
  static DAO _dao;

  DAO get getDatabaseAccessObject => _dao;

  static PWCUtils _pwcUtils;

  static String _projectPath;

  String get path {
    return _projectPath;
  }

  static DeviceDetails _deviceDetails;

  DeviceDetails get deviceDetails {
    return _deviceDetails;
  }

  static bool _isInit = false;

  static FilePersistor _filePersistor;

  FilePersistor get filePersistor {
    return _filePersistor;
  }

  static InitParams _initParms;

  InitParams get initParms {
    return _initParms;
  }

  static String _applicationVersion;

  String get applicationVersion {
    return _applicationVersion;
  }

  CorePlatware._internal();

  factory CorePlatware() {
    return _singleton;
  }

  static Future<bool> initPlatware(InitParams initParms) async {
    if (!_isInit) {
      final directory = await getApplicationDocumentsDirectory();
      _projectPath = directory.path;

      _pwcUtils = new PWCUtils();
      await _pwcUtils.getAllParamsFromFile();
      _initParms = initParms;
      _filePersistor = new FilePersistor();

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      _deviceDetails = new DeviceDetails();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceDetails.deviceModel = androidInfo.model;
        _deviceDetails.deviceMake = androidInfo.brand;
        _deviceDetails.androidVersion = androidInfo.version.baseOS;
        _deviceDetails.imeiNumber = androidInfo.androidId;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceDetails.deviceModel = iosInfo.model;
        _deviceDetails.deviceMake = iosInfo.name;
        _deviceDetails.androidVersion = iosInfo.systemName;
        _deviceDetails.imeiNumber = iosInfo.identifierForVendor;
      }
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _applicationVersion = packageInfo.version;

    if (_initParms.databaseName != null &&
        !Utility.isEmpty(_initParms.databaseName)) {
      _dao = SQLiteDAO.getDbInstance(_initParms.databaseName);
    }
    return Future.value(_isInit);
  }
}
