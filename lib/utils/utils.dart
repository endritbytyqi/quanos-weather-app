import 'package:intl/intl.dart';

class Utils {
  static String convertUnixToReadableHour(int unixTimestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);

    String formattedTime = DateFormat('h:mm a').format(date);

    return formattedTime;
  }
}
