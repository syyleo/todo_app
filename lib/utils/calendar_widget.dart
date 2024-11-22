import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? events = prefs.getString('events');
    if (events != null) {
      setState(() {
        _events = Map<DateTime, List<String>>.from(
          json.decode(events).map((key, value) =>
              MapEntry(DateTime.parse(key), List<String>.from(value))),
        );
      });
    }
  }

  Future<void> saveEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'events',
      json.encode(
        _events.map((key, value) =>
            MapEntry(key.toIso8601String(), value)),
      ),
    );
  }

  void _removeEvent(int index) {
    setState(() {
      _events[_selectedDay!]!.removeAt(index);
      if (_events[_selectedDay!]!.isEmpty) {
        _events.remove(_selectedDay!);
      }
      saveEvents();
    });
  }

  void _addEvent(BuildContext context) {
    TextEditingController _eventController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Event'),
        content: TextField(
          controller: _eventController,
          decoration: const InputDecoration(hintText: 'Event Details'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_eventController.text.isNotEmpty) {
                setState(() {
                  if (_events[_selectedDay!] != null) {
                    _events[_selectedDay!]!.add(_eventController.text);
                  } else {
                    _events[_selectedDay!] = [_eventController.text];
                  }
                  saveEvents();
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: TableCalendar(
            key: ValueKey(_calendarFormat), // Ensure a new key is used when the format changes
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.0),
              ),
              todayTextStyle: const TextStyle(color: Colors.white),
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: const TextStyle(color: Colors.white),
              selectedTextStyle: const TextStyle(color: Colors.white),
              outsideDaysVisible: false,
              markerDecoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              titleTextStyle: const TextStyle(color: Colors.white),
              formatButtonTextStyle: const TextStyle(color: Colors.white),
              formatButtonDecoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(12.0),
              ),
              leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
              headerMargin: const EdgeInsets.only(bottom: 8.0),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
              weekendStyle: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
            ),
            daysOfWeekHeight: 30, // Ensures the day names are fully visible
            eventLoader: (day) => _events[day] ?? [],
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Center(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      width: 30.0,
                      height: 30.0,
                      child: Center(
                        child: Text(
                          day.day.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),
        Expanded(
          child: _selectedDay != null && _events[_selectedDay!] != null
              ? ListView.builder(
                  itemCount: _events[_selectedDay!]!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text(
                          _events[_selectedDay!]![index],
                          style: const TextStyle(color: Colors.black),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeEvent(index),
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    'No Events',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
        ),
        Positioned(
          bottom: 16.0,
          left: MediaQuery.of(context).size.width / 2 - 28, // Adjust for centering
          child: FloatingActionButton(
            backgroundColor: Colors.deepPurple,
            onPressed: () => _addEvent(context),
            elevation: 6.0,
            shape: const CircleBorder(),
            child: const Icon(Icons.event),
          ),
        ),
      ],
    );
  }
}
