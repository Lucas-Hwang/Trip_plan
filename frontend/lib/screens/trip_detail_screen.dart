import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trip_provider.dart';
import '../services/socket_service.dart';
import 'itinerary_tab.dart';
import 'checklist_tab.dart';
import 'budget_tab.dart';
import 'discussion_tab.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final String tripId;
  final String tripTitle;

  const TripDetailScreen({super.key, required this.tripId, required this.tripTitle});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socket = ref.read(socketServiceProvider);
      socket.connect();
      socket.joinTrip(widget.tripId);
    });
  }

  @override
  void dispose() {
    final socket = ref.read(socketServiceProvider);
    socket.leaveTrip(widget.tripId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const Tab(icon: Icon(Icons.calendar_today), text: '行程'),
      const Tab(icon: Icon(Icons.checklist), text: '清单'),
      const Tab(icon: Icon(Icons.pie_chart), text: '预算'),
      const Tab(icon: Icon(Icons.chat), text: '讨论'),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.tripTitle),
          bottom: TabBar(
            tabs: tabs,
            onTap: (i) => setState(() => _tabIndex = i),
          ),
        ),
        body: TabBarView(
          children: [
            ItineraryTab(tripId: widget.tripId),
            ChecklistTab(tripId: widget.tripId),
            BudgetTab(tripId: widget.tripId),
            DiscussionTab(tripId: widget.tripId),
          ],
        ),
      ),
    );
  }
}
