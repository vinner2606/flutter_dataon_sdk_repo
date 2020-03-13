import 'package:pwc/response/Response.dart';

abstract class ServiceResponse {
  Future<List<Response>> getResponseList();

  Future<bool> validateHash();

  saveResponseInDB(List<Response> resList);
}
