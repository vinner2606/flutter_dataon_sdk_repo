import 'dart:convert';

import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/model/FilePersistor.dart';
import 'package:pwc/utility/Constants.dart';

import 'dart:io' show Platform;

class SaveFileUtility {
  FilePersistor filePersistor;
  PWCUtils pwcUtils;

  SaveFileUtility() {
    pwcUtils = PWCUtils();
    filePersistor = pwcUtils.mFilePersistor;
  }

  /**
   * Reads the syncConfig from response, parses it and stores it in new file
   * in the internal file directory of the application.
   */
  Future<bool> setProcessSyncConfig(List<Map> response) async {
    var isSuccess = false;
    if (response.length > 0) {
      isSuccess = await filePersistor.writeFile(
          Constants.PWSYNCCONFIG_FILENAME, json.encode(response));
    } else {
      print("setProcessSyncConfig" + "Row is empty");
      return false;
    }

    return isSuccess;
  }

  /**
   * Reads the auth response from server application, parses it and stores it
   * in new file in the internal file directory of the application.
   */
  Future<bool> setAuth(Map<String, Object> responseHeader) async {
    var platwareProperties =
        await filePersistor.getPlatwarePropertiesFromFile();
    var token = responseHeader["Authorization"];
    if (pwcUtils.decryptedKey != null && token != null) {
      //token =    await pwcUtils.encryptionUtil.encrypt(pwcUtils.decryptedKey, token);

    } else {
      throw (Exception(
          "Either Authentication token is null or decrypted key is null"));
    }
    platwareProperties?.token = token;
    platwareProperties?.key = pwcUtils.mPlatwareProperties?.key;
    pwcUtils.mPlatwareProperties?.isSessionExpired = false;
    platwareProperties?.isSessionExpired = false;
    await filePersistor.writeFile(Constants.PLATWARE_PROPERTIES_JSON_FILENAME,
        jsonEncode(platwareProperties.toJson()));
    return Future.value(true);
  }

  Future<bool> setRegistration(
      Object response, Map<String, Object> responseHeader) async {
    var platwareProperties =
        await filePersistor.getPlatwarePropertiesFromFile();
    if (response is Map) {
      Map<String, Object> data = response as Map<String, Object>;
      Map<String, Object> rsaObject;
      if (data["rsa"] is String) {
        rsaObject = jsonDecode(data["rsa"]);
      } else {
        rsaObject = jsonDecode(data["rsa"]);
      }
      platwareProperties.exponent = rsaObject["public-exponent"];
      if (Platform.isIOS) {
        platwareProperties.modulus = rsaObject["public-pem"];
      } else if (Platform.isAndroid)
        platwareProperties.modulus = rsaObject["public-modules"];
    }
    var registrationId = responseHeader["Authorization"];
    if (pwcUtils.decryptedKey == null && registrationId == null) {
      throw (Exception(
          "Either Registration token is null or decrypted key is null"));
    }
    platwareProperties?.registrationId = registrationId;
    platwareProperties?.key = pwcUtils.mPlatwareProperties?.key;

    // pwcUtils.mPlatwareProperties.registrationId = registrationId;

    bool status = await filePersistor.writeFile(
        Constants.PLATWARE_PROPERTIES_JSON_FILENAME,
        jsonEncode(platwareProperties.toJson()));
    return status;
  }

  Future<bool> setPropertyMaster(List<Map> list) {
    return filePersistor.writeFile(
        Constants.PROPERTY_MASTER_FILE_NAME, jsonEncode(list));
  }
}
