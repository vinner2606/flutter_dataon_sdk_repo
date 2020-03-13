import 'dart:io';

import 'package:flutter_downloader/flutter_downloader.dart';

/**
 * this file is using for download a file with showing notification and after successfull download
 * notification will actionable.
 *
 * */

class DownloadFileWorker {
  static final DownloadFileWorker _instance =
      new DownloadFileWorker._internal();

  factory DownloadFileWorker() => _instance;

  DownloadFileWorker._internal();

  void download(String url, String fileName, String path,
      {DownloadCallback callback}) async {
    final savedDir = Directory(path);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      fileName: fileName,
      savedDir: path,
      showNotification: true,
      // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );

    FlutterDownloader.registerCallback(callback);
    FlutterDownloader.registerCallback((id, status, progress) {
      if (DownloadTaskStatus.complete == status) {
        FlutterDownloader.registerCallback(null);
      }
      print(
          'Download task ($id) is in status ($status) and process ($progress)');
    });
  }
}
