import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/models/event_model.dart';
import 'package:proyecto_final/Page_Ui/widgets/metro_app_bar.dart';
import 'package:proyecto_final/Page_Ui/widgets/calendar_controls.dart';
import 'package:proyecto_final/Page_Ui/widgets/calendar_core_view.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  PageController? _pageController;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<EventModel>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  void _onTodayPressed() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
    });

    if (_pageController != null && _pageController!.hasClients) {
      final int targetPage =
          (_focusedDay.year - 2010) * 12 + _focusedDay.month - 1;
      _pageController!.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<EventModel> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MetroAppBar(
        title: 'Calendario',
        onBackPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, '/principal', (route) => false),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          CalendarControls(
            focusedDay: _focusedDay,
            onTodayPressed: _onTodayPressed,
            onLeftArrowTapped: () {
              if (_pageController != null && _pageController!.hasClients) {
                _pageController!.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            onRightArrowTapped: () {
              if (_pageController != null && _pageController!.hasClients) {
                _pageController!.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CalendarCoreView(
                    focusedDay: _focusedDay,
                    selectedDay: _selectedDay,
                    onDaySelected: _onDaySelected,
                    onPageChanged: _onPageChanged,
                    eventLoader: _getEventsForDay,
                    onCalendarCreated: (pageController) {
                      if (_pageController == null) {
                        _pageController = pageController;
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Eventos del día',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ..._getEventsForDay(_selectedDay ?? DateTime.now()).isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Text('No hay eventos para este día.'),
                          )
                        ]
                      : _getEventsForDay(_selectedDay ?? DateTime.now()).map(
                          (event) => ListTile(
                            leading: CircleAvatar(
                                backgroundColor: event.color, radius: 10),
                            title: Text(event.title),
                            subtitle:
                                Text(DateFormat.jm('es_ES').format(event.date)),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
