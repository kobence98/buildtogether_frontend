import 'package:flutter_frontend/languages/languages.dart';

class DateFormatter {
  static String formatDate(DateTime createdDate, Languages languages) {
    if (createdDate.isAfter(DateTime.now().subtract(Duration(hours: 1)))) {
      String minString = (DateTime.now().hour == createdDate.hour
                  ? DateTime.now().minute - createdDate.minute
                  : DateTime.now().minute + (60 - createdDate.minute))
              .toString() +
          languages.minuteLetter;
      return minString == '0${languages.minuteLetter}' ? languages.now : minString;
    }
    for (int i = 2; i < 24; i++) {
      if (createdDate.isAfter(DateTime.now().subtract(Duration(hours: i)))) {
        return (i - 1).toString() + languages.hourLetter;
      }
    }
    for (int i = 2; i < 21; i++) {
      if (createdDate.isAfter(DateTime.now().subtract(Duration(days: i)))) {
        return (i - 1).toString() + languages.dayLetter;
      }
    }
    return createdDate.year.toString() +
        '.' +
        _zeroToOneDigitNumbers(createdDate.month) +
        '.' +
        _zeroToOneDigitNumbers(createdDate.day) +
        '.' +
        _zeroToOneDigitNumbers(createdDate.hour) +
        ':' +
        _zeroToOneDigitNumbers(createdDate.minute);
  }

  static String _zeroToOneDigitNumbers(int number) {
    if (number < 10 && number >= -10) {
      return '0$number';
    }
    return number.toString();
  }
}
