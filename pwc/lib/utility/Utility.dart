import 'dart:io';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Utility {
  RegExp _ipv4Maybe =
      new RegExp(r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$');
  RegExp _ipv6 =
      new RegExp(r'^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$');

  /// check if the string matches the comparison
  bool equals(String str, comparison) {
    return str == comparison.toString();
  }

  /// check if the string contains the seed
  bool contains(String str, seed) {
    return str.indexOf(seed.toString()) >= 0;
  }

  /// check if string matches the pattern.
  bool matches(String str, pattern) {
    RegExp re = new RegExp(pattern);
    return re.hasMatch(str);
  }

  /// check if the string is a URL
  ///
  /// `options` is a `Map` which defaults to
  /// `{ 'protocols': ['http','https','ftp'], 'require_tld': true,
  /// 'require_protocol': false, 'allow_underscores': false,
  /// 'host_whitelist': false, 'host_blacklist': false }`.
  bool isValidURL(String str, [Map options]) {
    if (str == null ||
        str.length == 0 ||
        str.length > 2083 ||
        str.indexOf('mailto:') == 0) {
      return false;
    }

    Map default_url_options = {
      'protocols': ['http', 'https', 'ftp'],
      'require_tld': true,
      'require_protocol': false,
      'allow_underscores': false
    };

    options = _merge(options, default_url_options);

    var protocol,
        user,
        pass,
        auth,
        host,
        hostname,
        port,
        port_str,
        path,
        query,
        hash,
        split;

    // check protocol
    split = str.split('://');
    if (split.length > 1) {
      protocol = _shift(split);
      if (options['protocols'].indexOf(protocol) == -1) {
        return false;
      }
    } else if (options['require_protocols'] == true) {
      return false;
    }
    str = split.join('://');

    // check hash
    split = str.split('#');
    str = _shift(split);
    hash = split.join('#');
    if (hash != null && hash != "" && new RegExp(r'\s').hasMatch(hash)) {
      return false;
    }

    // check query params
    split = str.split('?');
    str = _shift(split);
    query = split.join('?');
    if (query != null && query != "" && new RegExp(r'\s').hasMatch(query)) {
      return false;
    }

    // check path
    split = str.split('/');
    str = _shift(split);
    path = split.join('/');
    if (path != null && path != "" && new RegExp(r'\s').hasMatch(path)) {
      return false;
    }

    // check auth type urls
    split = str.split('@');
    if (split.length > 1) {
      auth = _shift(split);
      if (auth.indexOf(':') >= 0) {
        auth = auth.split(':');
        user = _shift(auth);
        if (!new RegExp(r'^\S+$').hasMatch(user)) {
          return false;
        }
        pass = auth.join(':');
        if (!new RegExp(r'^\S*$').hasMatch(user)) {
          return false;
        }
      }
    }

    // check hostname
    hostname = split.join('@');
    split = hostname.split(':');
    host = _shift(split);
    if (split.length > 0) {
      port_str = split.join(':');
      try {
        port = int.parse(port_str, radix: 10);
      } catch (e) {
        return false;
      }
      if (!new RegExp(r'^[0-9]+$').hasMatch(port_str) ||
          port <= 0 ||
          port > 65535) {
        return false;
      }
    }

    if (!isIP(host) && !_isFQDN(host, options) && host != 'localhost') {
      return false;
    }

    if (options['host_whitelist'] == true &&
        options['host_whitelist'].indexOf(host) == -1) {
      return false;
    }

    if (options['host_blacklist'] == true &&
        options['host_blacklist'].indexOf(host) != -1) {
      return false;
    }

    return true;
  }

  /// check if the string is an IP (version 4 or 6)
  ///
  /// `version` is a String or an `int`.
  bool isIP(String str, [version]) {
    version = version.toString();
    if (version == 'null') {
      return isIP(str, 4) || isIP(str, 6);
    } else if (version == '4') {
      if (!_ipv4Maybe.hasMatch(str)) {
        return false;
      }
      var parts = str.split('.');
      parts.sort((a, b) => int.parse(a) - int.parse(b));
      return int.parse(parts[3]) <= 255;
    }
    return version == '6' && _ipv6.hasMatch(str);
  }

  /// check if the string is a fully qualified domain name (e.g. domain.com).
  ///
  /// `options` is a `Map` which defaults to `{ 'require_tld': true, 'allow_underscores': false }`.
  bool _isFQDN(str, [options]) {
    Map default_fqdn_options = {
      'require_tld': true,
      'allow_underscores': false
    };

    options = _merge(options, default_fqdn_options);
    List parts = str.split('.');
    if (options['require_tld']) {
      var tld = parts.removeLast();
      if (parts.length == 0 || !new RegExp(r'^[a-z]{2,}$').hasMatch(tld)) {
        return false;
      }
    }

    for (var part, i = 0; i < parts.length; i++) {
      part = parts[i];
      if (options['allow_underscores']) {
        if (part.indexOf('__') >= 0) {
          return false;
        }
      }
      if (!new RegExp(r'^[a-z\\u00a1-\\uffff0-9-]+$').hasMatch(part)) {
        return false;
      }
      if (part[0] == '-' ||
          part[part.length - 1] == '-' ||
          part.indexOf('---') >= 0) {
        return false;
      }
    }
    return true;
  }

  _shift(List l) {
    if (l.length >= 1) {
      var first = l.first;
      l.removeAt(0);
      return first;
    }
    return null;
  }

  Map _merge(Map obj, defaults) {
    if (obj == null) {
      obj = new Map();
    }
    defaults.forEach((key, val) => obj.putIfAbsent(key, () => val));
    return obj;
  }

  static String currentFormattedTimestamp(
      {dateFormat = "dd-MM-yyyy HH:mm:ss"}) {
    return DateFormat(dateFormat).format(DateTime.now());
  }

  static bool isEmpty(String str) {
    return str == null || str.length == 0;
  }

  static bool isAppIsInBackground() {
    var isInBackground = false;
    return isInBackground;
  }

  static bool checkDateChange(int date) {
    DateTime prevDate = DateTime.fromMillisecondsSinceEpoch(date);
    DateTime currentDate = DateTime.now();
    return currentDate.difference(prevDate).inDays > 0 ? true : false;
  }

  static String convertByteArrayToHexString(List<int> tempArray) {
    int v;
    if (tempArray == null) {
      return null;
    }
    StringBuffer sb = new StringBuffer(tempArray.length * 2);

    for (final aTempArray in tempArray) {
      v = aTempArray & 0xff;
      if (v < 16) {
        sb.write('0');
      }
      sb.write(aTempArray.toRadixString(16));
    }
    return sb.toString();
  }

  static Duration getDifferenceBetweenDates(
      String firstDateTimeStamp, String secondDateTimestamp,
      {String patternFirst, String pattenSecond}) {
    DateFormat format = new DateFormat(patternFirst ?? "dd-MM-yyyy HH:mm:ss");
    DateTime startDate = format.parse(firstDateTimeStamp);
    format = new DateFormat(pattenSecond ?? "dd-MM-yyyy HH:mm:ss");
    DateTime endDate = format.parse(secondDateTimestamp);
    return startDate.difference(endDate);
  }

  static DateTime getFormattedDate(String date, String pattern) {
    DateFormat format = new DateFormat(pattern);
    return format.parse(date);
  }

  static Map<String, Object> toMap(Map object) {
    Map<String, Object> map = new Map();
    object.forEach((key, value) {
      if (value is List) {
        value = toList(value as List);
      } else if (value is Map) {
        value = toMap(value as Map);
      }
      map[key] = value;
    });

    return map;
  }

  static List<Object> toList(List array) {
    List<Object> list = new List();

    array.forEach((value) {
      if (value is List) {
        value = toList(value as List);
      } else if (value is Map) {
        value = toMap(value as Map);
      } else {
        value = Map();
      }
      list.add(value);
    });
    return list;
  }

  static String getNotNullAndNotEmpty(List<String> items) {
    if (items != null) {
      for (String item in items) {
        if (item != null && !Utility.isEmpty(item)) {
          return item;
        }
      }
    }
    return null;
  }

  static void updateApp(String url, {bool bySystem = true}) async {
    if (bySystem) {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      Directory extDir = await getExternalStorageDirectory();
      String _localPath = "${extDir.path}/Download";
      final savedDir = Directory(_localPath);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        savedDir.create();
      }

      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: _localPath,
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );

      FlutterDownloader.registerCallback((id, status, progress) {
        if (DownloadTaskStatus.complete == status) {
          FlutterDownloader.registerCallback(null);
        }
        print(
            'Download task ($id) is in status ($status) and process ($progress)');
      });
    }
  }
}
