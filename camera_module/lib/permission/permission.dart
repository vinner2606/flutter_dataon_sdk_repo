import 'dart:io' show Platform;

import 'package:camera_module/interface/callback.dart';
import 'package:permission/permission.dart';

class MyPermission {
  List<PermissionName> permissionNameList;
  PermissionName permissionName;
  bool isAllow = true;
  int whenToSetCallback;

  /// PermissionCallback
  PermissionCallback callback;

  /// [NamedConstructor] for Android
  MyPermission.setPermission(this.permissionNameList, this.callback) {
    whenToSetCallback = permissionNameList.length;
  }

  /// getting Permission Status
  getPermissionStatus() async {
    await Permission.getPermissionsStatus(permissionNameList);
  }

  /// requesting Runtime Permission
  requestForPermission() async {
    await Permission.requestPermissions(permissionNameList)
        .then((permissionList) {
      permissionList.forEach((permission) {
        whenToSetCallback--;
        if (permission.permissionStatus != PermissionStatus.allow)
          isAllow = false;

        if (whenToSetCallback == 0) {
          isAllow ? callback.permissionAllowed() : callback.permissionDenied();
        }
      });
    });
  }
}
