import 'package:intl/intl.dart';

class Utils {
  static String convertUnixToReadableHour(int unixTimestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);

    String formattedTime = DateFormat('h:mm a').format(date);

    return formattedTime;
  }

  static String capitalizeFirstLetters(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
