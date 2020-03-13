class Util {

	static void logErrorWithErrorCode(String code, String message) => print('Error: $code\nMessage: $message');

	static void logError(String message) => print('Error Message: $message');

	static String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
}