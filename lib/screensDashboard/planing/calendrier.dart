import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // Import manquant ajouté ici


class PlanningGlobalPage extends StatefulWidget {
  const PlanningGlobalPage({super.key});

  @override
  State<PlanningGlobalPage> createState() => _PlanningGlobalPageState();
}

class _PlanningGlobalPageState extends State<PlanningGlobalPage> {
  // Déclaration cohérente
  late Map<DateTime, List<Map<String, dynamic>>> _events;
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _loadEvents();
  }

    Future<void> _loadEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('planning')
          .get();

      final loadedEvents = <DateTime, List<Map<String, dynamic>>>{};

      for (var doc in snapshot.docs) {
        final eventDate = (doc['date'] as Timestamp).toDate();
        final normalizedDate = DateTime(
          eventDate.year, 
          eventDate.month, 
          eventDate.day
        );

        final eventData = {
          'id': doc.id,
          'name': doc['event_name'] ?? 'Sans nom',
          'time': DateFormat.Hm().format(eventDate), // Formatage correct avec DateFormat
        };

        loadedEvents.update(
          normalizedDate,
          (existing) => [...existing, eventData],
          ifAbsent: () => [eventData],
        );
      }

      setState(() => _events = loadedEvents);
    } catch (e) {
      debugPrint('Erreur de chargement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }


  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalizedDate = DateTime(day.year, day.month, day.day);
    return _events[normalizedDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planning Global')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    final events = _getEventsForDay(_selectedDay);
    if (events.isEmpty) {
      return const Center(child: Text('Aucun événement cette date'));
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          child: ListTile(
            title: Text(event['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event['time']),
              ],
            ),
          ),
        );
      },
    );
  }
}
