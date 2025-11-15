import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_final/Color/Color.dart';

class CalendarControls extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onTodayPressed;
  final VoidCallback onLeftArrowTapped;
  final VoidCallback onRightArrowTapped;

  const CalendarControls({
    super.key,
    required this.focusedDay,
    required this.onTodayPressed,
    required this.onLeftArrowTapped,
    required this.onRightArrowTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: onTodayPressed,
            style: TextButton.styleFrom(
              foregroundColor: colorTextoPrincipal,
              backgroundColor: grisClaro,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: const Text('Hoy'),
          ),
          Row(
            children: [
              IconButton(
                icon:
                    const Icon(Icons.chevron_left, color: colorTextoSecundario),
                onPressed: onLeftArrowTapped,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right,
                    color: colorTextoSecundario),
                onPressed: onRightArrowTapped,
              ),
            ],
          ),
          Text(
            DateFormat.yMMMM('es_ES').format(focusedDay),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: colorTextoPrincipal,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.calendar_view_month_outlined,
                color: colorTextoSecundario),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
