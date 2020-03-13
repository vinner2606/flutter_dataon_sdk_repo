
import 'package:pwc/model/ErrorResponse.dart';
import 'package:pwc/model/Record.dart';
import 'package:pwc/request/service/ServiceRequest.dart';
import 'package:pwc/response/Response.dart';

abstract class ResponseParser {
  List<Response> parseResponse(Map res);
}

class ResponseParserPlatware20 extends ResponseParser {
  ServiceRequest serviceRequest;
  String KEY_ERROR = "error";
  String KEY_SERVICE = "services";
  String SEPRETOR = "~";
  String KEY_RECORDS = "records";
  String KEY_PRIMARY = "primary_key";
  String KEY_DATA = "data";
  String KEY_RESPONSE_HANDLED_BY = "responseHandledBy";
  String KEY_TABLE_NAME = "tableName";
  String KEY_RESPONSE_HANDLE_TYPE = "responseHandleType";
  String KEY_WHERE_CONDITION = "whereCondition";


  ResponseParserPlatware20(this.serviceRequest);

  @override
  List<Response> parseResponse(Map response) {
    if (response.containsKey(KEY_ERROR)) {
      return parseErrorResponse(response);
    } else {
      Map<String, Object> serviceJSON = response[KEY_SERVICE];
      var listResponse = List<Response>();
      serviceJSON.forEach((key, value) {
        Map<String, Object> responseJSON = value;
        var response = Response();
        if (responseJSON.containsKey(KEY_ERROR)) {
          var error = ErrorResponse.fromJson(responseJSON[KEY_ERROR]);
          response.error = error;
        }else{
          response.responseHandleBy = responseJSON[KEY_RESPONSE_HANDLED_BY];
          response.tableName = responseJSON[KEY_TABLE_NAME];
          response.responseHandleType = responseJSON[KEY_RESPONSE_HANDLE_TYPE];
          response.whereCondition = responseJSON[KEY_WHERE_CONDITION];
          List<Object> records = responseJSON[KEY_RECORDS]?? new List<Object>();
          var listRecord = List<Record>();

          records.forEach((obj){
            Map<String,Object> record =obj;
            var recordBO = Record();
            if(record.containsKey(KEY_ERROR))
            {
              var error = ErrorResponse.fromJson(record[KEY_ERROR]);
              recordBO.error = error;
            }else{
              recordBO.primaryKey = record[KEY_PRIMARY];
              recordBO.data = record[KEY_DATA];
            }
            listRecord.add(recordBO);
          });
          response.records = listRecord;
        }
        response.serviceName = key;
        listResponse.add(response);
      });
      return listResponse;
    }
  }

  List<Response> parseErrorResponse(Map map) {
    var errorJSON = map[KEY_ERROR];
    var error = ErrorResponse.fromJson(errorJSON);
    var processNames = serviceRequest.tagName().split(SEPRETOR);
    var list = List<Response>();
    processNames.forEach((it) {
      var res = new Response();
      res.error = error;
      list.add(res);
    });

    return list;
  }
}