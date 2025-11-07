import 'package:flutter/material.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/models/event_model.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarCoreView extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final List<EventModel> Function(DateTime) eventLoader;
  final Function(PageController) onCalendarCreated;

  const CalendarCoreView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.eventLoader,
    required this.onCalendarCreated,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar<EventModel>(
      locale: 'es_ES',
      firstDay: DateTime.utc(2010, 1, 1),
      lastDay: DateTime.utc(2040, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      onCalendarCreated: onCalendarCreated,
      eventLoader: eventLoader,
      headerVisible: false,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: colorTextoSecundario),
        weekendStyle: TextStyle(color: primaryRed),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: lightOrange.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(color: colorTextoPrincipal),
        selectedDecoration: const BoxDecoration(
          color: primaryBlue,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(color: Colors.white),
        markerDecoration: const BoxDecoration(
          color: primaryOrange,
          shape: BoxShape.circle,
        ),
        weekendTextStyle: const TextStyle(color: primaryRed),
        outsideDaysVisible: true,
        outsideTextStyle: TextStyle(color: Colors.grey[400]),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;

          return Positioned(
            bottom: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: events
                  .take(4)
                  .map((event) => Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: event.color,
                          shape: BoxShape.circle,
                        ),
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
