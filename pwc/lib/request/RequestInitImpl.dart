import 'package:pwc/model/PlatwarePropertyModel.dart';
import 'package:pwc/model/enums.dart';
import 'package:pwc/request/Request.dart';

class RequestInitImpl extends Request {
  Map<String, String> interfaceParam;
  var serviceName;
  bool isSpecialProcess = true;
  InitParams initParams;
  Task task;

  RequestInitImpl(this.task, this.initParams, [this.interfaceParam]) {
    this.serviceName = "Init";
    this.isSpecialProcess = true;
    this.task = task;
    this.initParams = initParams;
    this.interfaceParam = interfaceParam;
  }

  @override
  List<Map<String, dynamic>> getRequest() {
    return [];
  }
}
