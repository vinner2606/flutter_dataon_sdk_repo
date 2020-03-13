import 'dart:convert';

import 'package:pwc/datastore/DAO.dart';
import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/model/RecordSyncBO.dart';
import 'package:pwc/model/SyncTableBO.dart';
import 'package:pwc/model/enums.dart';
import 'package:pwc/request/service/ServiceRequest.dart';
import 'package:pwc/response/NetResponse.dart';
import 'package:pwc/response/Response.dart';
import 'package:pwc/response/ResponseParser.dart';
import 'package:pwc/response/ServiceResponse.dart';
import 'package:pwc/security/EncryptionFactory.dart';
import 'package:pwc/sync/RequestOutSync.dart';
import 'package:pwc/utility/AppSharedPreference.dart';
import 'package:pwc/utility/Constants.dart';
import 'package:pwc/utility/SaveFileUtility.dart';
import 'package:pwc/utility/Utility.dart';
import 'package:sqflite/sqflite.dart';

class ServiceResponseImpl extends ServiceResponse {
  ServiceRequest serviceRequest;
  NetResponse netResponse;
  PWCUtils mPWCUtil = PWCUtils();
  ResponseParserPlatware20 responseParser;

  ServiceResponseImpl(this.serviceRequest, this.netResponse) {
    responseParser = new ResponseParserPlatware20(serviceRequest);
  }

  @override
  Future<List<Response>> getResponseList() async {
    var data;
    if (serviceRequest.getCallingType() == CallingType.ER_ER) {
      Map encryptedResponse = json.decode(netResponse.data);
      netResponse.data = encryptedResponse["response"];
      var time = DateTime.now();
      data = await mPWCUtil.encryptionUtil
          .decrypt(serviceRequest.getTxtKey(), netResponse.data);
      print("response :" + data);
      var time1 = DateTime.now();
      print(
          "time difference in decryption ${time1.difference(time).inMilliseconds}");
    } else {
      data = netResponse.data;
    }
    print("response recieved");
    Map<String, Object> resJSON = json.decode(data);
    return responseParser.parseResponse(resJSON);
  }

  @override
  Future<bool> validateHash() async {
    Map<String, Object> header = netResponse.header;
    var hashValue = header["hash"];
    var hashGenerator = EncryptionFactory.getCheckSumGenerator(
        Constants.TYPE_CHECKSUM_GENERATOR);
    var responseHashValue = await hashGenerator.generateCheckSum(
        serviceRequest.getTxtKey(), netResponse.data ?? "");
    return Future.value(responseHashValue == hashValue);
  }

  @override
  saveResponseInDB(List<Response> resList) async {
    var dao = mPWCUtil.getDao();
    for (var response in resList) {
      var request = serviceRequest.getRequestList().firstWhere((element) {
        return element.serviceName == response.serviceName;
      }, orElse: () {
        return null;
      });
      if (request != null && request is RequestOutSync) {
        await saveOutboundSyncData(response, dao, request);
      }
      await saveInboundData(response, dao);
      await saveSpecialProcessResponse(response);
    }
    var flag = resList.singleWhere((element) {
      return Constants.arrSpecialProcess.contains(element.serviceName);
    }, orElse: () {
      return null;
    });
    if (flag != null) {
      mPWCUtil.isConfigurationChanged = true;
    }
  }

  saveOutboundSyncData(
      Response response, DAO dao, RequestOutSync requestOutSync) async {
    var tableSyncBO = requestOutSync.tableBO;
    if (response.records != null && tableSyncBO != null) {
      try {
        List responseArray = response.getNotNullData();
        var listRecordSyncBO =
            generateRecordSyncBOs(tableSyncBO, responseArray);
        var noRowAffected =
            await dao.updateSyncAttributesOfRecords(listRecordSyncBO);
        print(noRowAffected);
        mPWCUtil.updateTableConfigOnSuccess(
            tableSyncBO,
            responseArray.length,
            Utility.currentFormattedTimestamp(
                dateFormat: DateTimeFormat.HH_mm_ss));
      } catch (e, stacktrace) {
        print(stacktrace);
      }
    } else {
      mPWCUtil.updateTableConfigOnError(
          tableSyncBO, response.error?.message ?? "");
    }
  }

  saveSpecialProcessResponse(Response it) {
    if (Constants.arrSpecialProcess
        .contains(it.serviceName.toString().toUpperCase())) {
      if (it.error == null && it.records?.elementAt(0)?.error == null) {
        var saveFileUtility = new SaveFileUtility();
        handleAllConfiguration(it, saveFileUtility);
      } else {
        throw Exception(it.error?.message ??
            it.records?.elementAt(0)?.error?.message ??
            "some error occured in ${it.serviceName}");
      }
    }
  }

  handleAllConfiguration(
      Response response, SaveFileUtility saveFileUtility) async {
    var recordData = response.getNotNullData();
    if (response.serviceName == Constants.SERVICE_AUTH) {
      saveFileUtility.setAuth(netResponse.header);
    } else if (response.serviceName == Constants.SERVICE_SYNC_CONFIG) {
      saveFileUtility.setProcessSyncConfig(recordData);
    } else if (response.serviceName == Constants.SERVICE_REGISTER_APP) {
      await saveFileUtility.setRegistration(recordData[0], netResponse.header);
    } else if (response.serviceName == Constants.SERVICE_PROPERTY_MASTER) {
      AppSharedPreference appSharedPreference =
          await AppSharedPreference.getInstance();
      await appSharedPreference.putValue(
          AppSharedPreference.LAST_PROPERTY_SYNC_TIME,
          new DateTime.now().millisecondsSinceEpoch);
      saveFileUtility.setPropertyMaster(recordData);
    }
  }

  List<RecordSyncBO> generateRecordSyncBOs(
      SyncTableBO tableSyncBO, List responseArray) {
    var listRecordSyncBO = List<RecordSyncBO>();
    responseArray.forEach((item) {
      if (item is Map) {
        Map<String, Object> singleRecordDetail = item;
        RecordSyncBO recordSyncBO = RecordSyncBO.fromJson(singleRecordDetail);
        recordSyncBO.syncFlagColumnName = tableSyncBO.syncFlagColumnName;
        recordSyncBO.errorRemarksColumnName = tableSyncBO.errorRemarksColumn;
        recordSyncBO.syncTimeStampColumnName =
            tableSyncBO.recordsSyncTimestampColumnName;
        if (singleRecordDetail["ISSUCCESSFUL"].toString().toUpperCase() ==
            "SUCCESS") {
          recordSyncBO.syncFlagValue = tableSyncBO.flagOnSuccess;
        } else {
          recordSyncBO.syncFlagValue = tableSyncBO.flagOnError;
        }
        try {
          if (recordSyncBO.tableName.isNotEmpty &&
              recordSyncBO.primaryKeyColumnName.isNotEmpty) {
            listRecordSyncBO.add(recordSyncBO);
          }
        } catch (ex, stackTrace) {
          print(stackTrace);
        }
      }
    });
    return listRecordSyncBO;
  }

  saveInboundData(Response it, DAO dao) async {
    try {
      if (it.error == null) {
        var tableName = it.tableName;
        var recordsDataList = it.getNotNullData();
        if (it.responseHandleBy == null) {
          return;
        }

        if ("PWC" == it.responseHandleBy.toUpperCase() &&
            tableName != null &&
            it.responseHandleType != null) {
          var whereClause = it.whereCondition;
          if (it.responseHandleType.toUpperCase() == "RELOAD") {
            if (!(Utility.isEmpty(whereClause) && "null" != whereClause)) {
              await dao?.replaceSyncTypeOfTableData(
                  tableName, recordsDataList, whereClause);
            } else {
              await dao?.replaceTableData(tableName, recordsDataList);
            }
          } else if (it.responseHandleType.toUpperCase() == "DELETE") {
            await dao?.delete(tableName);
          } else if (it.responseHandleType.toUpperCase() == "APPEND") {
            await dao?.insertBulkData(tableName, recordsDataList,
                conflictAlgorithm: ConflictAlgorithm.ignore);
          } else if (it.responseHandleType.toUpperCase() == "APPEND_REPLACE") {
            if (!(Utility.isEmpty(whereClause) && "null" != whereClause)) {
              await dao?.appendReplace(tableName, recordsDataList, whereClause,
                  conflictAlgorithm: ConflictAlgorithm.replace);
            } else {
              await dao?.insertBulkData(tableName, recordsDataList,
                  conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }
        }
      }
    } catch (ex, stacktrace) {
      print(stacktrace);
    }
  }
}
