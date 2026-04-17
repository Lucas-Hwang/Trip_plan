import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/trip_provider.dart';
import '../services/api_service.dart';
import 'trip_detail_screen.dart';

class TripsListScreen extends ConsumerWidget {
  const TripsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的旅行计划'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (trips) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: trips.length,
          itemBuilder: (_, i) {
            final trip = trips[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.flight, color: Colors.deepOrange),
                title: Text(trip.title),
                subtitle: Text('${trip.destination} · ${trip.startDate.toLocal().toString().split(" ")[0]}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TripDetailScreen(tripId: trip.id, tripTitle: trip.title)),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTrip(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateTrip(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final destCtrl = TextEditingController();
    DateTime start = DateTime.now();
    DateTime end = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('新建旅行计划'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: '标题')),
              TextField(controller: destCtrl, decoration: const InputDecoration(labelText: '目的地')),
              ListTile(
                title: const Text('开始日期'),
                subtitle: Text(start.toLocal().toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(context: ctx, initialDate: start, firstDate: DateTime(2024), lastDate: DateTime(2030));
                  if (d != null) setState(() => start = d);
                },
              ),
              ListTile(
                title: const Text('结束日期'),
                subtitle: Text(end.toLocal().toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(context: ctx, initialDate: end, firstDate: DateTime(2024), lastDate: DateTime(2030));
                  if (d != null) setState(() => end = d);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            FilledButton(
              onPressed: () async {
                final api = ref.read(apiServiceProvider);
                await api.createTrip({
                  'title': titleCtrl.text,
                  'destination': destCtrl.text,
                  'startDate': start.toIso8601String(),
                  'endDate': end.toIso8601String(),
                });
                ref.invalidate(tripsProvider);
                if (context.mounted) Navigator.pop(ctx);
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );
  }
}
