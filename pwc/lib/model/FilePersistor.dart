import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pwc/model/PlatwarePropertyModel.dart';
import 'package:pwc/utility/Constants.dart';
import 'package:synchronized/synchronized.dart';

class FilePersistor {
  static FilePersistor _singleton = new FilePersistor._internal();
  static var lock = new Lock();

  FilePersistor._internal();

  factory FilePersistor() {
    return _singleton;
  }

  PlatwareProperties _platwarePropertiesFromFile;

  Future<PlatwareProperties> getPlatwarePropertiesFromFile() async {
    try {
      var fileData =
          await readFile(Constants.PLATWARE_PROPERTIES_JSON_FILENAME);
      if (fileData != null && fileData.isNotEmpty) {
        _platwarePropertiesFromFile =
            PlatwareProperties.fromJson(jsonDecode(fileData));
      }
    } catch (e, stacktrace) {
      print(stacktrace);
    }
    return _platwarePropertiesFromFile;
  }

  PWcData _pWcData;

  Future<PWcData> getPwcDataFromFile() async {
    try {
      var fileData = await readFile(Constants.PLATWARE_DATA_FILENAME);
      if (fileData == null || fileData.isEmpty) {
        _pWcData = new PWcData(null);
      } else {
        _pWcData = new PWcData(fileData);
      }
    } catch (e, stacktrace) {
      print(stacktrace);
    }
    return _pWcData;
  }

  Future<String> readFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    String directoryPath = directory.path;
    File file = new File("$directoryPath/$fileName");
    //var pathToFile = join(dirname(Platform.script.toFilePath()), '..', fileName);

    if (!file.existsSync()) {
      file.createSync();
    }
    String contents = await file.readAsString();
    return contents;
  }

  Future<bool> writeFile(String fileName, String data) async {
    final directory = await getApplicationDocumentsDirectory();
    String directoryPath = directory.path;
    File file = new File("$directoryPath/$fileName");

    if (!file.existsSync()) {
      file.createSync();
    }
    File temp = await file.writeAsString(data);
    print("file $fileName " + temp.readAsStringSync());
    return true;
  }

  Future<bool> isFilePresent(String fileName) async {
    if (fileName == null) {
      return false;
    }

    final directory = await getApplicationDocumentsDirectory();
    String directoryPath = directory.path;
    File file = new File("$directoryPath/$fileName");

    if (file.existsSync()) {
      return true;
    }
    return false;
  }

  Future<String> readAFile(File file) async {
    String fileData;
    if (file.existsSync()) {
      fileData = await file.readAsString();
      return fileData;
    }
  }
}
