import 'package:pwc/model/enums.dart';

abstract class Constants {
  static String PLATWARE_CLIENT_VERSION = "2.0";

  //File Names
  static String PROPERTY_MASTER_FILE_NAME = "PROPERTY_MASTER_FILE.json";
  static String PWSYNCCONFIG_FILENAME = "PROCESS_SYNC_CONFIG_GROUP_TABLE.json";
  static String PLATWARE_PROPERTIES_JSON_FILENAME = "PLATWARE_PROPERTIES.json";
  static String PLATWARE_DATA_FILENAME = "PWC_DATA.json";

  static int PWSYNC_REQUEST_CODE = 1001;

/* Platware JSON keys */
  static String X_REQUEST_ID = "X_REQUEST_ID";

  static String AUTH_TYPE = "authType";
  static String KEY_LOGIN_ID = "LOGIN_ID";
  static String KEY_SIM_ID = "SIM_ID";
  static String KEY_DEVICE_TIMESTAMP = "DEVICE_TIMESTAMP";
  static String KEY_OS_VERSION = "OS_VERSION";
  static String KEY_PW_CLIENT_VERSION = "PW_CLIENT_VERSION";
  static String KEY_APP_VERSION = "APPLICATION_VERSION";
  static String KEY_PW_VERSION = "PW_VERSION";

  static String KEY_CLIENT_ID = "clientid";

  static String KEY_OUT_PROCESS_ID = "servicename";

  static String KEY_PASSWORD = "password";
  static String KEY_IMEI_NO = "IMEI_NO";
  static String KEY_DEVICE_MAKE = "DEVICE_MAKE";
  static String KEY_DEVICE_MODEL = "DEVICE_MODEL";
  static String KEY_DEVICE_LATITUDE = "DEVICE_LATITUDE";
  static String KEY_DEVICE_LONGITUDE = "DEVICE_LONGITUDE";
  static String KEY_PLATFORM = "platform";

  static String FILE_NOT_FOUND_ERROR = "no such file or directory";
  static String ERROR = "ERROR";
  static int AES_KEY_LENGTH = 128;
  static int AES_KEY_GENERATION_ITERATION_COUNT = 100;

  static int INT_CALL_PROCESS_GROUP_LIMIT =
      5; // number of process will be called

  static String PSYCHE_KEY_GROUP = "SyncGroupBO";

// in group

  static int NOTIFICATION_SYNC_SHUDULE_DEADLINE_MINUTES =
      60; // notification shedule time
  // static String TYPE_CHECKSUM_GENERATOR = CheckSumType.SHA512;
  static String SESSION_EXPIRED_MESSAGE = "Session Expired";
  static String PW_UNSYNCED_PROCESS_KEY = "pw_unsynced_process_key";
  static String PW_SHARED_FILE_NAME = "pw_shared_pre";

  static String KEY_URL_FOR_APK = "ANDROID_APK_URL";
  static String KEY_VERSION_UPDATE_MANDATORY = "IS_VERSION_UPGRADE_MANDATORY";
  static String KEY_VERSION_UPDATE_TYPE = "VERSION_UPGRADE_TYPE";
  static String ERROR_INVALIDSESSION = "INVALID SESSION";
  static String KEY_INTERFACE = "interfaces";
  static String KEY_REQUEST = "request";
  static String KEY_REQUESTID = "requestid";
  static String KEY_TXN_KEY = "txnkey";
  static String HASH_VALUE = "hash";

  static const String SERVICE_AUTH = "AUTH";
  static const String SERVICE_REGISTER_APP = "REGISTERAPP";
  static const String SERVICE_KILL_SESSION = "PWKILLSESSION";
  static const String SERVICE_KILL_ALL_SESSION = "PWKILLALLSESSION";
  static const String SERVICE_PROPERTY_MASTER = "PROPERTYMASTER";
  static const String SERVICE_SYNC_CONFIG = "PWSYNCCONFIG";

  static String ERROR_DATABASE_NULL = "Database is null";

/*  var arrSpecialProcess = arrayOf(Constants.SERVICE_REGISTER_APP, Constants.SERVICE_AUTH,
      Constants.SERVICE_SYNC_CONFIG, Constants.SERVICE_PROPERTY_MASTER, Constants.SERVICE_KILL_SESSION,
      Constants.SERVICE_KILL_ALL_SESSION)*/
  static String KEY_REQUESTTYPE = "requesttype";
  static String KEY_AUTHORIZATION = "Authorization";
  static String KEY_SERVICES = "services";
  static String ERROR_AUTH_FAILURE = "Authentication failed";
  static String AUTHENTICATION_ERROR = "402";
  static String REGISTER_ERROR = "401";
  static String MULTIPLE_SESSION = "621";
  static String ERROR_DEVICE_REGISTRATION = "Device registration is failed";
  static String KEY_VERSION_NUMBER = "LATEST_APK_VERSION_NO";
  static String KEY_PWC_CONFIG_VERSION = "PWC_SYNC_CONFIG_VERSION";
  static int REQUEST_TIMEOUT = 60000;
  static String KEY_NOUNCE = "nounce";
  static String KEY_STATUS = "status";
  static String KEY_MESSAGE = "message";
  static String KEY_ERRORHINT = "errorHint";
  static String KEY_IS_FORCE_LOGIN = "isforcelogin";
  static String PROPERTY_IS_FORCE_LOGIN = "IS_FORCE_LOGIN";
  static const String SERVICE_LOGOUT = "LOGOUT";
  static String MSG_MULTIPLE_SESSION = "Multiple session is not allowed";
  static String LOGOUT_SESSION = "625";
  static String KEY_SECUIRITY_VERSION = "security-version";
  static String CURRENT_SECURITY_VERSION = "2";

  static var TYPE_CHECKSUM_GENERATOR = CheckSumType.SHA512;

  static List arrSpecialProcess = [
    Constants.SERVICE_REGISTER_APP,
    Constants.SERVICE_AUTH,
    Constants.SERVICE_SYNC_CONFIG,
    Constants.SERVICE_PROPERTY_MASTER,
    Constants.SERVICE_KILL_SESSION,
    Constants.SERVICE_KILL_ALL_SESSION
  ];
}
