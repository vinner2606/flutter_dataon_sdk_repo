abstract class SyncListener {
  void onSyncCompleted();
  void onGroupSynced(String groupId);
  void onIOExceptionOccured(String error, {String code});
}
