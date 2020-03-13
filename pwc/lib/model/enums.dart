enum Task { INIT, SERVICE, AUTHENTICATE, LOGOUT, KILL_ALL_SESSION }
enum RequestProcessor { BATCH, OLTP }
enum PriorityServerCall { LOW, NORMAL, HIGH, IMMEDIATE }

/// Permissions status enum (iOS)
enum PermissionStatus { allow, deny, notDecided, notAgain, whenInUse, always }
enum PermissionName {
  // iOS
  Internet, // both
  Calendar, // both
  Camera, // both
  Contacts, // both
  Microphone, // both
  Location, // Android
  Phone, // Android
  Sensors, // Android
  SMS, // Android
  Storage
}
enum ConnectionHandler { VOLLEY }


enum  EncryptionType {
  AES, RSA
}

enum  CheckSumType {
  HMAC,SHA512
}
abstract class DateTimeFormat{
static var HH_mm_ss="HH:mm:ss";
static var YY_MM_DD_HH_MM_SS_SSS="yyMMddHHmmssSSS";
static var DD_MM_YYYY_HH_MM_SS_SSS="ddMMyyyyHHmmssS";


}

abstract class Enum<T> {
	final T value;

	const Enum(this.value);
}

class CallingType<String> extends Enum<String> {
	const CallingType(String val) : super(val);

	static const CallingType PR_PR   = const CallingType("PR_PR");
	static const CallingType ER_ER = const CallingType("ER_ER");
	static const CallingType ER_PR    = const CallingType("ER_PR");
}
