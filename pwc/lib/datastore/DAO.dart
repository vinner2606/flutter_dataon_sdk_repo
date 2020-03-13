import 'dart:async';

import 'package:pwc/model/RecordSyncBO.dart';
import 'package:sqflite/sqflite.dart';

abstract class DAO<T, U> {
  String tag;

  Future<Database> getDatabase();

  Future openSqliteDatabase();

  Future closeSqliteDatabase();

  Future<int> insertBulkData(String tableName, List<Map> data,
      {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace});

  Future<int> delete(String tableName,
      {String whereClause, List<String> whereArgs});

  Future<void> executeQuery(String query);

  Future<int> update(String tableName, Map<String, Object> value,
      String whereClause, List<String> whereArgs);

  Future<String> getSyncFlagValue(RecordSyncBO recordSyncBO);

  Future<int> getUnSyncedRecordCount(
      String tableName, String syncFlagWhereClause);

   appendReplace(
      String tableName, List<Map> recordsDataList, String syncFlagWhereClause,
      {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace});

  Future<bool> replaceTableData(String tableName, List<Map> data);

  Future<bool> replaceSyncTypeOfTableData(
      String tableName, List<Map> data, String syncFlagWhereClause);

  Future<int> updateSyncAttributesOfRecords(List<RecordSyncBO> recordSyncBOs);

  Future<List<Map<String, Object>>> performDBOperation(String query);
}
