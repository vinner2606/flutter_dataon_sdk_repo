import 'package:pwc/listeners/PWCCallback.dart';
import 'package:pwc/request/Request.dart';
import 'package:pwc/response/Response.dart';

abstract class ResponseCommandReciever {
  void authenticateUser();

  void registerUser(Function callback, PWCCallback<List<Response>> mCallback);

  Future<List<Response>> handleResponse();

  Request killMultipleSession(Request request);

  void logoutUser();
}
