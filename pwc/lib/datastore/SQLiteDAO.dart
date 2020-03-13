import 'dart:async';

import 'package:path/path.dart';
import 'package:pwc/datastore/DAO.dart';
import 'package:pwc/model/RecordSyncBO.dart';
import 'package:pwc/utility/Utility.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteDAO extends DAO {
  static final SQLiteDAO _sqLiteDAO = new SQLiteDAO._internal();
  static var _DB_NAME;

  static var _DB_VERSION = 1;

  SQLiteDAO._internal();

  static SQLiteDAO getDbInstance(String databaseName, {int version}) {
    _DB_NAME = databaseName;
    _DB_VERSION = version;
    return _sqLiteDAO;
  }

  Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await _initDb();
    return _db;
  }

  //Creating a database with name test.dn in your directory
  _initDb() async {
//    Sqflite.setDebugModeOn(true);
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _DB_NAME);
    _db = await openDatabase(path,
        version: _DB_VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return _db;
  }

  Future _onCreate(Database db, int version) async {}

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  @override
  appendReplace(
      String tableName, List<Map> recordsDataList, String syncFlagWhereClause,
      {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
    var _db = await db;
    List<Map> list = await _db
        .rawQuery("SELECT * FROM $tableName WHERE " + "$syncFlagWhereClause");
    print(list);
    insertBulkData(tableName, recordsDataList);
  }

  @override
  void closeDatabase() {
    // TODO: implement closeDatabase
  }

  @override
  Future<int> delete(String tableName,
      {String whereClause, List<String> whereArgs}) async {
    var _db = await db;
    var deletedRow =
        await _db?.delete(tableName, where: whereClause, whereArgs: whereArgs);
    return deletedRow;
  }

  @override
  Future<void> executeQuery(String query) async {
    try {
      var _db = await db;
      await _db.execute(query);
    } catch (e, stacktrace) {
      print("Exception  =  $query  ");
      print(stacktrace);
    }
  }

  @override
  Future<String> getSyncFlagValue(RecordSyncBO recordSyncBO) async {
    var syncFlagValue = "";
    try {
      var _db = await db;
      var selection = recordSyncBO.primaryKeyColumnName + " = ?";
      var selectionArgs = [recordSyncBO.primaryKeyValue];
      var columns = [recordSyncBO.syncFlagColumnName];
      List<Map<String, dynamic>> data = await _db.query(recordSyncBO.tableName,
          columns: columns, where: selection, whereArgs: selectionArgs);

      if (data != null && data.length > 0) {
        syncFlagValue = data.elementAt(0)[recordSyncBO.syncFlagColumnName];
      }
    } catch (e) {}
    return syncFlagValue;
  }

  @override
  Future<int> getUnSyncedRecordCount(
      String tableName, String syncFlagWhereClause) async {
    var numberOfUnSyncedRecord = 0;
    try {
      var _db = await db;
      var cursor = await _db?.rawQuery(
          "SELECT 1 FROM $tableName WHERE " + "$syncFlagWhereClause", null);
      numberOfUnSyncedRecord = cursor ?? 0;
    } catch (e, stacktrace) {
      print(stacktrace);
    }
    return numberOfUnSyncedRecord;
  }

  @override
  Future<int> insertBulkData(String tableName, List<Map> data,
      {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
    if (data == null || data.isEmpty) return 0;
    var _db = await db;
    var startTimestamp = 0;
    var rowsAffected = 0;
    var partitionSize = 3000;
    var partitions = List<List<Map>>();
    var i = 0;
    while (i < data.length) {
      partitions.add(data.sublist(
          i,
          i +
              (partitionSize <= data.length - i
                  ? partitionSize
                  : (data.length - i))));
      i += partitionSize;
    }

    startTimestamp = DateTime.now().millisecondsSinceEpoch;
    var tableColumns = List<String>();

    List<Map<String, Object>> tableInfo =
        await _db?.rawQuery("PRAGMA table_info($tableName)");
    tableInfo.forEach((obj) {
      if (obj is Map) {
        obj.keys.forEach((key) {
          try {
            tableColumns.add(obj[key]);
          } catch (ex) {}
        });
      }
    });
    for (final splitList in partitions) {
      for (final jsonResponse in splitList) {
        var values = Map<String, Object>();

        jsonResponse.forEach((key, value) {
          if (tableColumns.contains(key)) {
            values[key] = value;
          }
        });
        if (values.isNotEmpty) {
          var rowId = await _db.insert(tableName, values,
              conflictAlgorithm: ConflictAlgorithm.replace,
              nullColumnHack: null);
          if (rowId != null && rowId >= 0) {
            rowsAffected += 1;
          } else {
            rowsAffected += 0;
          }
        }
      }
    }

    return rowsAffected;
  }

  @override
  Future<int> update(String tableName, Map<String, Object> value,
      String whereClause, List<String> whereArgs) async {
    var numberOfRowUpdated = 0;
    try {
      var _db = await db;
      numberOfRowUpdated = await _db?.update(tableName, value,
          where: whereClause, whereArgs: whereArgs);
    } catch (e, stacktrace) {
      print(stacktrace);
    }
    return numberOfRowUpdated;
  }

  @override
  Future<bool> replaceTableData(String tableName, List<Map> data) async {
    var numberOfRowDeleted = await delete(tableName);
    print("Row deleted is : $numberOfRowDeleted");
    var rowAffected = await insertBulkData(tableName, data);
    bool returnBool = !(rowAffected < 0 || numberOfRowDeleted < 0);
    return Future.value(returnBool);
  }

  @override
  Future<bool> replaceSyncTypeOfTableData(
      String tableName, List<Map> data, String syncFlagWhereClause) async {
    var numberOfRowDeleted =
        await delete(tableName, whereClause: " not ($syncFlagWhereClause) ");
    print("Row deleted is : $numberOfRowDeleted");
    var rowAffected = await insertBulkData(tableName, data,
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return Future.value(!(rowAffected <= 0 || numberOfRowDeleted <= 0));
  }

  @override
  Future<int> updateSyncAttributesOfRecords(
      List<RecordSyncBO> recordSyncBOs) async {
    try {
      var rowsAffected = 0;

      for (final recordSyncBO in recordSyncBOs) {
        var syncFlagValue = await getSyncFlagValue(recordSyncBO);
        if ((recordSyncBO.syncFlagValue?.toLowerCase() == "delete") ||
            (recordSyncBO.action?.toLowerCase == "delete")) {
          print("Sync flag delete " + recordSyncBO.toString());
          var whereArgs = [recordSyncBO?.primaryKeyValue];
          rowsAffected = await delete(recordSyncBO.tableName ?? null,
              whereClause: recordSyncBO.primaryKeyColumnName + " = ?",
              whereArgs: whereArgs);
        } else if (recordSyncBO.syncFlagValue?.toLowerCase == "process") {
          return 0;
        } else if ("query" == recordSyncBO.action?.toLowerCase()) {
          print(tag +
              "Action is query ${recordSyncBO.actionQuery} on Table ${recordSyncBO.tableName}");
          if (!Utility.isEmpty(recordSyncBO.actionQuery)) {
            try {
              if (!recordSyncBO?.actionQuery?.contains("^")) {
                executeQuery(recordSyncBO.actionQuery);
              } else {
                var arrQueries = recordSyncBO?.actionQuery?.split("\\^");
                for (final query in arrQueries) {
                  executeQuery(query);
                }
              }
            } catch (ex) {
              ex.printStackTrace();
            }
          } else {
            print("query" + "Action query is empty");
          }
        } else if (syncFlagValue?.toLowerCase() == "w") {
          var values = Map<String, Object>();
          values[recordSyncBO.syncFlagColumnName] = recordSyncBO.syncFlagValue;
          values[recordSyncBO.syncTimeStampColumnName] =
              recordSyncBO.lastSyncTimestamp;
          values[recordSyncBO.errorRemarksColumnName] =
              recordSyncBO.errorRemarks;
          var whereArgs = [recordSyncBO.primaryKeyValue];
          print("Sync flag Y " + recordSyncBO.toString());
          rowsAffected += await update(recordSyncBO.tableName, values,
              recordSyncBO.primaryKeyColumnName + " = ?", whereArgs);
        }
      }
      return rowsAffected;
    } catch (ex, stacktrace) {
      print(stacktrace);
    }
    return 0;
  }

  List<Map<String, Object>> getProcessData(
      List<Map<String, Object>> cursorData) {}

  @override
  Future<List<Map<String, Object>>> performDBOperation(String query) async {
    var _db = await db;
    List<Map<String, Object>> processedData = new List();

    List<Map<String, Object>> data = await _db.rawQuery(query);
    if (data != null && data.length > 0) {
      data.asMap().forEach((key, value) {
        Map<String, Object> temp = new Map();
        value.keys.forEach((key) {
          temp[key] = value[key] ?? "";
        });
        processedData.add(temp);
      });
    }
    return processedData;
  }

  @override
  Future closeSqliteDatabase() async {
    return _db.close();
  }

  @override
  Future openSqliteDatabase() async {
    _initDb();
  }

  @override
  Future<Database> getDatabase() async {
    return await db;
  }
}
