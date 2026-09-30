import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreatePostScheduleSheet {
  static Future<DateTime?> pick(BuildContext context,
      {DateTime? initial}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Schedule date',
    );
    if (date == null || !context.mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(initial ?? now.add(const Duration(hours: 1))),
      helpText: 'Schedule time',
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  static String format(DateTime value) =>
      DateFormat('MMM d, yyyy · h:mm a').format(value);
}
