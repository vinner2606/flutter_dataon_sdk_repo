import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:pwc/internal/PWCClient.dart';
import 'package:pwc/internal/PWCUtils.dart';
import 'package:pwc/listeners/PWCCallback.dart';
import 'package:pwc/model/FilePersistor.dart';
import 'package:pwc/model/SyncGroupBO.dart';
import 'package:pwc/model/SyncTableBO.dart';
import 'package:pwc/model/enums.dart';
import 'package:pwc/request/Request.dart';
import 'package:pwc/request/RequestHashImp.dart';
import 'package:pwc/response/Response.dart';
import 'package:pwc/sync/RequestOutSync.dart';
import 'package:pwc/sync/SyncListener.dart';
import 'package:pwc/utility/AppSharedPreference.dart';
import 'package:pwc/utility/Constants.dart';
import 'package:pwc/utility/Pair.dart';
import 'dart:math' as Math;
import 'package:pwc/utility/Utility.dart';

class SyncApi {
  Map<String, String> _interfaceParam = Map();
  RequestProcessor mRequestProcessor = RequestProcessor.BATCH;
  PWCUtils mPWCUtils;
  List<String> mGroupNameList;
  int maxRecordSyncCount =
      1; // bydefault these number of record will be send to server.

  static const TAG = "SyncApi";
  static const TYPE_SYNC_INBOUND = "inbound";
  static const TYPE_SYNC_OUTBOUND = "outbound";
  static const SYNC_REQUEST_DEFAULT_TIMEOUT = 90000;

  SyncApi.name(this._interfaceParam) {
    SyncApi();
  }

  SyncApi() {
    mPWCUtils = PWCUtils();
    mGroupNameList = List();
  }

  void syncGroups(
      List<String> listGroupId, bool isManualSync, SyncListener syncListener) {
    if (!initialValidationforInternet(syncListener)) return;
    mGroupNameList = listGroupId.map((st) => st).toList();
    if (!checkForSyncConfigurataion(syncListener)) return;

    mGroupNameList.asMap().forEach((index, groupId) async {
      var syncGroupBO = mPWCUtils.mSyncGroupBO.singleWhere((element) {
        return element?.groupId.toLowerCase() == groupId.toLowerCase();
      }, orElse: () => null);
      if (syncGroupBO != null) {
        asyncSaveConfiguration() async {
          mPWCUtils.saveSyncConfiguration();
        }

        if (!(syncGroupBO.recurringType.toLowerCase() == "never") ||
            isManualSync) {
          int batteryLevel = await mPWCUtils.batteryLevel;
          int battery = 0;
          if (syncGroupBO.minimumBatteryThreshold != null &&
              syncGroupBO.minimumBatteryThreshold.isNotEmpty) {
            battery = int.parse(syncGroupBO.minimumBatteryThreshold);
          }
          if (((batteryLevel >= battery) || mPWCUtils.charging) ||
              isManualSync) {
            if (syncGroupBO.scheduleSyncStartTimestamp?.isEmpty != false) {
              var currentTimestamp = Utility.currentFormattedTimestamp();
              String previousTimestamp = syncGroupBO.lastAttempTimestamp ?? "";

              if (previousTimestamp.isNotEmpty &&
                  !(previousTimestamp.toLowerCase() == "null")) {
                var dateDiff = Utility.getDifferenceBetweenDates(
                    currentTimestamp, previousTimestamp);
                int syncFrequency = 0;
                if (syncGroupBO.syncFrequency != null &&
                    syncGroupBO.syncFrequency.isNotEmpty) {
                  syncFrequency = int.parse(syncGroupBO.syncFrequency);
                }
                if (dateDiff.inMinutes >= syncFrequency || isManualSync) {
                  executeGroup(syncGroupBO, syncListener);
                  syncGroupBO.lastAttempTimestamp =
                      Utility.currentFormattedTimestamp();
                  asyncSaveConfiguration();
                } else {
                  mGroupNameList.remove(groupId);
                }
              } else {
                executeGroup(syncGroupBO, syncListener);
                print(TAG +
                    "length is 0-> last_attempt_timestamp->" +
                    Utility.currentFormattedTimestamp());
                syncGroupBO.lastAttempTimestamp =
                    Utility.currentFormattedTimestamp();
                asyncSaveConfiguration();
              }
            } else {
              // this is a scheduled group
              mGroupNameList.remove(groupId);
              if (!(syncGroupBO.isShceduled.toLowerCase() == "true")) {
                _scheduleGroupGroupSync(syncGroupBO, index);
              }
            }
          }
        }
      } else {
        syncListener?.onIOExceptionOccured("Invalid Group $groupId");
      }
    });
  }

  void _scheduleGroupGroupSync(SyncGroupBO syncGroupBO, int index) async {
    try {
      setAlarm(syncGroupBO, index);
      syncGroupBO.isShceduled = "true";
      mPWCUtils.saveSyncConfiguration();
    } catch (e, stacktrace) {
      print(stacktrace);
    }
  }

  /**
   * execute groups according to their type
   */

  executeGroup(SyncGroupBO syncGroupBO, SyncListener syncListener) {
    try {
      if (!Utility.isEmpty(syncGroupBO.syncType)) {
        var listTableBO = syncGroupBO.tables;
        if (listTableBO == null && listTableBO.isEmpty) {
          return;
        }

        switch (syncGroupBO?.syncType.toLowerCase()) {
          case TYPE_SYNC_INBOUND:
            callInboundOutboundProcesses(
                syncGroupBO, listTableBO, syncListener, getInboundRequestData);
            break;
          case TYPE_SYNC_OUTBOUND:
            callInboundOutboundProcesses(syncGroupBO, listTableBO, syncListener,
                getCompleteUnSyncedData);
            break;
        }
      }
    } catch (e, stacktrace) {
      print(stacktrace);
    }
  }

  callInboundOutboundProcesses(SyncGroupBO syncGroupBO,
      List<SyncTableBO> listTable, SyncListener syncListener, Function function,
      {List<String> records}) async {
    if (listTable.length > 0) {
      var tablesList = listTable.where((item) {
        return item.tablename != null;
      }).toList();
      tablesList.sort((element1, element2) {
        return element1.tableSequence - element2.tableSequence;
      });
      var requestList = List<Request>();
      FilePersistor filePersistor = FilePersistor();
      var platwareProperties =
          await filePersistor.getPlatwarePropertiesFromFile();
      if (platwareProperties != null && !platwareProperties.isSessionExpired) {
        for (final tableSyncBO in tablesList) {
          List<Map<String, Object>> data;
          Stopwatch stopwatch = new Stopwatch()..start();
          try {
            data = await function(tableSyncBO, records);
          } catch (e) {
            data = await function(tableSyncBO);
          }
          print(
              'sync upload execution time ${stopwatch.elapsed.inMilliseconds}');
          stopwatch = null;

          if (data != null && data.isNotEmpty) {
            var requestBO;
            if (syncGroupBO.syncType == SyncApi.TYPE_SYNC_OUTBOUND) {
              RequestOutSync requestOutSync = RequestOutSync(
                  tableSyncBO.processName, data, _interfaceParam);
              requestOutSync.tableBO = tableSyncBO;
              requestBO = requestOutSync;
            } else {
              requestBO = RequestHashImp(tableSyncBO.processName,
                  body: data, interfaceParam: _interfaceParam);
            }
            requestBO.priority = PriorityServerCall.LOW;
            requestBO.requestTimeout = SYNC_REQUEST_DEFAULT_TIMEOUT;
            requestBO.requestProcessor = mRequestProcessor;
            requestList.add(requestBO);
          } else {
            print(TAG +
                "No data available for sync for table " +
                tableSyncBO.tablename);
          }
        }
        if (requestList.isNotEmpty) {
          makeRequestToPlatware(
              requestList, tablesList, syncListener, syncGroupBO);
        } else {
          print(TAG + "No unsynced data in table");
          mGroupNameList.remove(syncGroupBO.groupId);
          syncListener?.onGroupSynced(syncGroupBO.groupId);
        }
        if (mGroupNameList.isEmpty) syncListener?.onSyncCompleted();
      } else {
        syncListener?.onIOExceptionOccured(Constants.SESSION_EXPIRED_MESSAGE,
            code: "622");
        /*mPWCUtils.moveToLoginActivity()
             Loger.e(TAG, "session expired on ${syncGroupBO.groupId}")
        }*/
      }
    } else {
      mGroupNameList.remove(syncGroupBO.groupId);
      syncListener?.onGroupSynced(syncGroupBO.groupId);
      if (mGroupNameList.isEmpty) {
        syncListener?.onSyncCompleted();
      }
    }
  }

  Pair<SyncGroupBO, List<SyncTableBO>> getGroupAndTableBO(
      String groupID, List<String> listTable, SyncListener syncListener) {
    var groupBO = mPWCUtils.mSyncGroupBO.singleWhere((element) {
      return element?.groupId?.toLowerCase() == groupID.toLowerCase();
    }, orElse: () => null);
    if (groupBO == null) {
      var invalidGroupMessage =
          "Group Id $groupID does not exist in configuration";
      syncListener?.onIOExceptionOccured(invalidGroupMessage);
      return null;
    }
    List<SyncTableBO> listTableBO = [];
    for (final tableName in listTable) {
      var tableBO = groupBO.tables.singleWhere((element) {
        return element?.tablename?.toLowerCase() == tableName.toLowerCase();
      }, orElse: () => null);

      if (tableBO != null) {
        listTableBO.add(tableBO);
      } else {
        var invalidTableNameError =
            "tableName $tableName does not exist in group $groupID";
        syncListener?.onIOExceptionOccured(invalidTableNameError);
      }
    }
    return Pair(groupBO, listTableBO);
  }

  List<Map<String, Object>> getInboundRequestData(SyncTableBO tableBO) {
    List<Map<String, Object>> request = new List();
    Map<String, Object> map = new Map();
    if (tableBO.sendLastAttemptServerTimestamp?.toLowerCase() == "y") {
      bool flag = tableBO.lastAttemptServerTimestamp?.length > 0 ? true : false;
      if (flag) {
        map["last_attempt_server_timestamp"] =
            tableBO.lastAttemptServerTimestamp;
      } else {
        map["last_attempt_server_timestamp"] = "01-01-1900 00:00:00";
      }
    } else if (tableBO.sendLastAttemptServerTimestamp?.toLowerCase() == "h") {
      map["last_attempt_server_timestamp"] = "01-01-1900 00:00:00";
    }
    request = [map];

    return request;
  }

  String getInRecordListFromRecord(List<String> records) {
    var inRecordArguments = "(";
    for (final recordId in records) {
      inRecordArguments += "\"$recordId\",";
    }
    if (inRecordArguments != "(") {
      inRecordArguments =
          inRecordArguments.substring(0, inRecordArguments.length - 1);
    }
    inRecordArguments += ")";
    return inRecordArguments;
  }

  Map<SyncGroupBO, List<SyncTableBO>> getTableBOfromProcessID(
      List<String> listProcess, SyncListener syncListener) {
    var mapTables = Map<SyncGroupBO, List<SyncTableBO>>();

    listProcess.forEach((processId) {
      mPWCUtils.mSyncGroupBO.asMap().forEach((index, groupBO) {
        var tableBO = groupBO.tables.singleWhere((element) {
          return element?.processName == processId;
        }, orElse: () => null);

        if (tableBO != null) {
          if (mapTables.containsKey(groupBO))
            mapTables[groupBO]?.add(tableBO);
          else {
            mapTables[groupBO] = [tableBO];
          }
          if (tableBO == null && index == mPWCUtils.mSyncGroupBO.length - 1) {
            syncListener?.onIOExceptionOccured(
                "$processId is not available in sync configuration");
          }
        }
      });
    });

    return mapTables;
  }

  SyncTableBO getTableBo(String processId) {
    SyncTableBO tableBO;
    for (SyncGroupBO groupBO in mPWCUtils.mSyncGroupBO) {
      tableBO = groupBO.tables.singleWhere((element) {
        return element?.processName == processId;
      }, orElse: () => null);
      if (tableBO != null) {
        return tableBO;
      }
    }
    return tableBO;
  }

  void syncProcess(List<String> listProcess, SyncListener syncListener) {
    if (!initialValidationforInternet(syncListener)) return;
    if (!checkForSyncConfigurataion(syncListener)) return;

    var mapTable = getTableBOfromProcessID(listProcess, syncListener);
    mGroupNameList = mapTable.keys.map((ob) {
      return ob.groupId;
    }).toList();
    if (mapTable.isEmpty) {
      syncListener
          .onIOExceptionOccured("Service Name does not exist in Config");
      return;
    }
    mapTable.forEach((groupBo, listTableBo) {
      if (groupBo.syncType != null && groupBo.groupId != null) {
        switch (groupBo?.syncType.toLowerCase()) {
          case TYPE_SYNC_OUTBOUND:
            callInboundOutboundProcesses(
                groupBo, listTableBo, syncListener, getCompleteUnSyncedData);
            break;
          case TYPE_SYNC_INBOUND:
            callInboundOutboundProcesses(
                groupBo, listTableBo, syncListener, getInboundRequestData);
            break;
        }
      }
    });
  }

  bool checkForSyncConfigurataion(SyncListener syncListener) {
    if (mPWCUtils.mSyncGroupBO == null) {
      mPWCUtils.loadAllConfigurations();
      if (mPWCUtils.mSyncGroupBO == null) {
        var syncConfError = "Sync configuration is not available";
        syncListener?.onIOExceptionOccured(syncConfError);

        return false;
      }
    }
    return true;
  }

  bool initialValidationforInternet(SyncListener syncListener) {
    if (!mPWCUtils.isInternetConnected) {
      syncListener?.onIOExceptionOccured("Internet Not available");
      return false;
    }
    return true;
  }

  ///get complete unsynced data for outbound processes

  Future<List<Map<String, Object>>> getCompleteUnSyncedData(
      SyncTableBO syncTableBo) async {
    try {
      var dao = mPWCUtils.getDao();
      var updateQuery =
          "UPDATE  ${syncTableBo.tablename} SET ${syncTableBo.syncFlagColumnName}  = 'W' WHERE ${syncTableBo.syncFlagWhereClause}";
      await dao?.executeQuery(updateQuery);
      var selectTable;
      if (syncTableBo.viewName == null || syncTableBo.viewName.isEmpty) {
        selectTable = syncTableBo.tablename;
      } else {
        selectTable = syncTableBo.viewName;
      }
      // now get all data whose sync status is W
      var query =
          "SELECT * FROM $selectTable WHERE ${syncTableBo.syncFlagColumnName} ='W' limit 500";
      List<Map<String, Object>> data = await dao?.performDBOperation(query);
      return data;
    } catch (ex) {
      print(ex);
      return [Map<String, Object>()];
    }
  }

  startSync() async {
    try {
      var platwareProperties =
          await mPWCUtils.mFilePersistor.getPlatwarePropertiesFromFile();
      var autoSyncTimeInMinutes =
          platwareProperties?.initParams?.autoSyncDuration ?? 30;
      callback() {
        var syncApi = SyncApi();
        var pwcUtil = PWCUtils();
        var listGroupName =
            pwcUtil.mSyncGroupBO.map((obj) => obj.groupId).toList();
        syncApi.syncGroups(listGroupName, false, new CallbackSyncListener());
        syncApi.startSync();
      }

      Duration duration =
          Duration(milliseconds: autoSyncTimeInMinutes * 60 * 1000);
      await AndroidAlarmManager.initialize();
      await AndroidAlarmManager.oneShot(
          duration, Constants.PWSYNC_REQUEST_CODE, callback);
      mPWCUtils.scheduleJobForNotification();
    } catch (ex, stacktrace) {
      print(stacktrace);
    }
  }

  void stopSync(int id) async {
    await AndroidAlarmManager.initialize();
    await AndroidAlarmManager.cancel(id);
  }

  void makeRequestToPlatware(
      List<Request> requestList,
      List<SyncTableBO> listTableSyncBO,
      SyncListener syncListener,
      SyncGroupBO syncGroupBO) {
    updateLastSyncRecordCountCallback(responseList) {
      updateLastSyncRecordCount(responseList);
    }

    List<Request> remainingRequestList = [];
    requestList = requestList.map((Request request) {
      if (request is RequestOutSync &&
          (request?.getRequest()?.length ?? 0) >
              (request.tableBO.recordSyncLimit ?? 50)) {
        var data = request.getRequest();
        int endOfSubList =
            Math.min(data.length, (request.tableBO.recordSyncLimit ?? 50));
        var batchData = data.sublist(0, endOfSubList);
        if (endOfSubList < data.length) {
          var remaingData = data.sublist(endOfSubList, data.length);
          var remainingRequestOut = RequestOutSync(
              request.serviceName, remaingData, request.interfaceParam);
          remainingRequestOut.tableBO = request.tableBO;
          remainingRequestList.add(remainingRequestOut);
        }
        var requestOut = RequestOutSync(
            request.serviceName, batchData, request.interfaceParam);
        requestOut.tableBO = request.tableBO;
        return requestOut;
      } else {
        return request;
      }
    })?.toList();
    PlatwareCallback platwareCallback = new PlatwareCallback(
        mPWCUtils,
        listTableSyncBO,
        mGroupNameList,
        syncGroupBO,
        syncListener,
        updateLastSyncRecordCountCallback,
        remainingRequestList,
        this);
    var pwcClient = PWCClient.getInstance();
    pwcClient.executeRequest(platwareCallback, requestList);
  }

  updateLastSyncRecordCount(List<Response> responseList) {
    try {
      var syncResponseRecord = 0;
      responseList.forEach((response) {
        syncResponseRecord += response.getNotNullData().length;
      });
      AppSharedPreference.getInstance().then((pref) {
        pref.putValue(
            AppSharedPreference.KEY_LAST_DATA_SYNC_COUNT, syncResponseRecord);
      });
    } catch (ex, stacktrace) {
      print(stacktrace);
    }
  }

  /// sync list of table corrosponding group Id
  syncTableViaGroupId(
      List<String> listGroupId, bool isManualSync, SyncListener syncListener) {
    if (!initialValidationforInternet(syncListener)) return;

    if (!checkForSyncConfigurataion(syncListener)) return;
    listGroupId.asMap().forEach((index, groupId) async {
      var syncGroupBO = mPWCUtils.mSyncGroupBO.singleWhere((element) {
        return element?.groupId?.toLowerCase() == groupId.toLowerCase();
      }, orElse: () => null);

      if (syncGroupBO != null) {
        if (!(syncGroupBO.recurringType.toLowerCase() == "never") ||
            isManualSync) {
          // Loger.d(TAG, "Group name :  ${syncGroupBO.groupId}  sync_type : ${syncGroupBO.syncType}")
          int batteryLevel = await mPWCUtils.batteryLevel;

          int battery = 0;
          if (syncGroupBO.minimumBatteryThreshold != null &&
              syncGroupBO.minimumBatteryThreshold.isNotEmpty) {
            battery = int.parse(syncGroupBO.minimumBatteryThreshold);
          }
          if (((batteryLevel >= battery) || mPWCUtils.charging) ||
              isManualSync) {
            if (syncGroupBO.scheduleSyncStartTimestamp?.isEmpty != false) {
              var currentTimestamp = Utility.currentFormattedTimestamp();
              var previousTimestamp = syncGroupBO.lastAttempTimestamp ?? "";

              if (previousTimestamp.isNotEmpty &&
                  !(previousTimestamp == "null")) {
                var dateDiff = Utility.getDifferenceBetweenDates(
                    currentTimestamp, previousTimestamp);
                int syncFrequency = 0;
                if (syncGroupBO.syncFrequency != null &&
                    syncGroupBO.syncFrequency.isNotEmpty) {
                  syncFrequency = int.parse(syncGroupBO.syncFrequency);
                }

                if (dateDiff.inMinutes >= syncFrequency || isManualSync) {
                  executeGroup(syncGroupBO, syncListener);

                  syncGroupBO.lastAttempTimestamp =
                      Utility.currentFormattedTimestamp();
                  mPWCUtils.saveSyncConfiguration();
                } // sync time difference check ends here
                else {
                  mGroupNameList.remove(groupId);
                }
              } // last_attempt_timestamp length check
              else {
                executeGroup(syncGroupBO, syncListener);
                /*Loger.d(TAG, "length is 0-> last_attempt_timestamp->" + Utility
                         .currentFormattedTimestamp());*/
                syncGroupBO.lastAttempTimestamp =
                    Utility.currentFormattedTimestamp();

                mPWCUtils.saveSyncConfiguration();
              }
            } else {
              // this is a scheduled group
              mGroupNameList.remove(groupId);
              if (!(syncGroupBO.isShceduled.toLowerCase() == "true")) {
                _scheduleGroupGroupSync(syncGroupBO, index);
              }
            }
          }
        }
      } else {
        syncListener?.onIOExceptionOccured("Invalid Group $groupId");
        //Loger.e(TAG, "Invalid group $groupId")
      }
    });
  }

  /**
   * sync list of table corrosponding group Id
   * @param hashGroupTable - hash of groupID and corrosponding tables in it to sync.
   */
  void syncListOfTableViaGroupId(
      Map<String, List<String>> hashGroupTable, SyncListener syncListener) {
    if (!initialValidationforInternet(syncListener)) return;
    if (!checkForSyncConfigurataion(syncListener)) return;

    hashGroupTable.forEach((groupId, listTable) {
      var groupTablePair = getGroupAndTableBO(groupId, listTable, syncListener);
      if (groupTablePair.first.syncType != null &&
          groupTablePair.first.groupId != null) {
        switch (groupTablePair.first.syncType.toLowerCase()) {
          case TYPE_SYNC_OUTBOUND:
            callInboundOutboundProcesses(groupTablePair.first,
                groupTablePair.second, syncListener, getCompleteUnSyncedData);
            break;
          case TYPE_SYNC_INBOUND:
            callInboundOutboundProcesses(groupTablePair.first,
                groupTablePair.second, syncListener, getInboundRequestData);
            break;
        }
      }
    });
  }

  /**
   * This method is for sync perticular record in given table of perticular groupID.
   */

  syncSelectedRecord(SyncListener syncListener, String groupID,
      String tableName, List<String> recordId) {
    if (!initialValidationforInternet(syncListener)) return;
    if (!checkForSyncConfigurataion(syncListener)) return;
    var groupTablePair = getGroupAndTableBO(groupID, [tableName], syncListener);
    if (groupTablePair != null && groupTablePair?.first?.syncType != null) {
      switch (groupTablePair.first.syncType.toLowerCase()) {
        case TYPE_SYNC_OUTBOUND:
          callInboundOutboundProcesses(groupTablePair.first,
              groupTablePair.second, syncListener, getUnSyncedData,
              records: recordId);
          break;
      }
    }
  }

  /**
   * get complete unsynced data for outbound processes
   */
  getUnSyncedData(SyncTableBO syncTableBo, {List<String> records}) async {
    try {
      var dao = mPWCUtils.getDao();

      var inRecordList = getInRecordListFromRecord(records);
      var updateQuery =
          "UPDATE  ${syncTableBo.tablename} SET ${syncTableBo.syncFlagColumnName}  = 'W' WHERE ${syncTableBo.syncFlagWhereClause} and ${syncTableBo.primaryKey} in $inRecordList";
      await dao?.executeQuery(updateQuery);
      var selectTable;
      if (syncTableBo.viewName.isEmpty) {
        selectTable = syncTableBo.tablename;
      } else {
        selectTable = syncTableBo.viewName;
      }
      // now get all data whose sync status is W
      var query =
          "SELECT * FROM $selectTable WHERE ${syncTableBo.syncFlagColumnName} ='W' and ${syncTableBo.primaryKey} in $inRecordList limit 500";
      return await dao?.performDBOperation(query);
    } catch (ex) {
      return [Map<String, String>()];
    }
  }

  alarmCallback(Map<String, Object> map) {
    SyncApi syncApi = new SyncApi();
    SyncGroupBO singleGroupConfig = map[Constants.PSYCHE_KEY_GROUP];
    syncApi.executeGroup(singleGroupConfig, new CallbackSyncListener());
  }

  void setAlarm(SyncGroupBO singleGroupConfig, int requestCode) async {
    Map<String, Object> map = new Map();
    map[Constants.PSYCHE_KEY_GROUP] = singleGroupConfig;
    final int alarmId = 1010;
    callback(Map data) {
      SyncApi syncApi = new SyncApi();
      SyncGroupBO singleGroupConfig = data[Constants.PSYCHE_KEY_GROUP];
      syncApi.executeGroup(singleGroupConfig, new CallbackSyncListener());
    }

    await AndroidAlarmManager.initialize();
    await AndroidAlarmManager.cancel(alarmId);
    await AndroidAlarmManager.periodic(
        const Duration(days: 1), alarmId, callback(map));
  }
}

class PlatwareCallback extends PWCCallback<List<Response>> {
  PWCUtils mPWCUtils;
  List<SyncTableBO> listTableSyncBO;
  List<String> mGroupNameList;
  SyncGroupBO syncGroupBO;
  SyncListener syncListener;
  Function callbackUpdateLastSyncRecordCount;
  List<Request> remainingRequestList;
  SyncApi syncApi;

  PlatwareCallback(
      this.mPWCUtils,
      this.listTableSyncBO,
      this.mGroupNameList,
      this.syncGroupBO,
      this.syncListener,
      this.callbackUpdateLastSyncRecordCount,
      this.remainingRequestList,
      this.syncApi);

  @override
  onFailure(String ex, {String code}) {
    syncListener?.onIOExceptionOccured(ex, code: code);
    syncListener = null;
    listTableSyncBO.forEach((syncBo) {
      mPWCUtils.updateTableConfigOnError(syncBo, "IO Exception");
    });
    if (remainingRequestList != null && remainingRequestList.isNotEmpty) {
      this.syncApi.makeRequestToPlatware(
          remainingRequestList, listTableSyncBO, syncListener, syncGroupBO);
    }
  }

  @override
  onResponse(List<Response> responseList) {
    try {
      var flag = responseList.where((element) {
        return element.error != null;
      });

      /*if (flag != null) {
        syncListener?.onIOExceptionOccured(
            responseList[0].error?.message ?? Constants.ERROR);
      }*/

      AppSharedPreference.getInstance().then((pref) {
        pref.putValue(AppSharedPreference.KEY_LAST_DATA_SYNC_TIME,
            DateTime.now().millisecondsSinceEpoch);
      });
      callbackUpdateLastSyncRecordCount(responseList);
      if (remainingRequestList == null || remainingRequestList.isEmpty) {
        var isRemoved = mGroupNameList.remove(syncGroupBO.groupId);
        if (isRemoved) {
          syncListener?.onGroupSynced(syncGroupBO.groupId);
        }
        if (mGroupNameList.isEmpty) {
          syncListener?.onSyncCompleted();
        }
        if (syncGroupBO.syncType == SyncApi.TYPE_SYNC_INBOUND) {
          listTableSyncBO.forEach((obj) {
            obj.lastAttemptServerTimestamp =
                Utility.currentFormattedTimestamp();
            mPWCUtils.saveSyncConfiguration();
          });
        }
      } else {
        this.syncApi.makeRequestToPlatware(
            remainingRequestList, listTableSyncBO, syncListener, syncGroupBO);
      }
    } catch (ex) {
      syncListener?.onIOExceptionOccured(ex.toString() ?? Constants.ERROR);
    }
  }
}

class CallbackSyncListener extends SyncListener {
  @override
  void onGroupSynced(String groupId) {
    // TODO: implement onGroupSynced
  }

  @override
  void onIOExceptionOccured(String error, {String code}) {
    // TODO: implement onIOExceptionOccured
  }

  @override
  void onSyncCompleted() {
    // TODO: implement onSyncCompleted
  }
}

enum SyncType { T }
