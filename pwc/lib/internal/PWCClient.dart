import 'package:pwc/datastore/DAO.dart';
import 'package:pwc/internal/PWCClientImpl.dart';
import 'package:pwc/listeners/PWCCallback.dart';
import 'package:pwc/request/Request.dart';
import 'package:pwc/response/Response.dart';

abstract class PWCClient {
  static PWCClientImpl getInstance() {
    return PWCClientImpl();
  }

  executeRequest(
      PWCCallback<List<Response>> callback, List<Request> requestList);

  openSyncScreen() {}

  Future<bool> isSessionExpired();

  DAO getDAO();

  Future<String> getLastSyncCount();

  Future<String> getLastSyncTime();
}
