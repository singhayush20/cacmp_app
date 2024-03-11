import 'package:intl/intl.dart';

String formatDateTime(DateTime dateTime) {
  String formattedDateTime =
  DateFormat('MMMM dd, yyyy hh:mm a', 'en').format(dateTime);
  return formattedDateTime;
}
