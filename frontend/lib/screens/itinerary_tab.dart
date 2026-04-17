import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/itinerary.dart';
import '../providers/trip_provider.dart';
import '../services/socket_service.dart';
import 'itinerary_edit_screen.dart';

class ItineraryTab extends ConsumerStatefulWidget {
  final String tripId;
  const ItineraryTab({super.key, required this.tripId});

  @override
  ConsumerState<ItineraryTab> createState() => _ItineraryTabState();
}

class _ItineraryTabState extends ConsumerState<ItineraryTab> {
  @override
  void initState() {
    super.initState();
    final socket = ref.read(socketServiceProvider);
    socket.tripUpdates.listen((data) {
      ref.read(itineraryNotifierProvider(widget.tripId).notifier).syncFromSocket(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itineraryNotifierProvider(widget.tripId));

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (items) {
        final grouped = <int, List<Itinerary>>{};
        for (final it in items) {
          grouped.putIfAbsent(it.dayIndex, () => []).add(it);
        }
        final days = grouped.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: days.length,
          itemBuilder: (_, dIdx) {
            final day = days[dIdx];
            final dayItems = grouped[day]!..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                initiallyExpanded: true,
                title: Text('第 $day 天', style: const TextStyle(fontWeight: FontWeight.bold)),
                children: dayItems.map((it) => _ItineraryTile(tripId: widget.tripId, item: it)).toList(),
              ),
            );
          },
        );
      },
    );
  }
}

class _ItineraryTile extends ConsumerWidget {
  final String tripId;
  final Itinerary item;
  const _ItineraryTile({required this.tripId, required this.item});

  Color _typeColor(ItineraryType t) {
    switch (t) {
      case ItineraryType.food: return Colors.orange;
      case ItineraryType.sight: return Colors.blue;
      case ItineraryType.shopping: return Colors.purple;
      case ItineraryType.relax: return Colors.green;
      case ItineraryType.transport: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Checkbox(
        value: item.done,
        onChanged: (v) async {
          final updated = item.copyWith(done: v ?? false);
          await ref.read(itineraryNotifierProvider(tripId).notifier).updateItem(updated);
        },
      ),
      title: Row(
        children: [
          if (item.time != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
              child: Text(item.time!, style: const TextStyle(fontSize: 12)),
            ),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(decoration: item.done ? TextDecoration.lineThrough : null, color: item.done ? Colors.grey : null),
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Chip(
            label: Text(item.type.name, style: const TextStyle(fontSize: 10)),
            backgroundColor: _typeColor(item.type).withOpacity(0.15),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          if (item.cost > 0) ...[
            const SizedBox(width: 8),
            Text('¥${item.cost}', style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.comments.isNotEmpty)
            Badge(
              label: Text('${item.comments.length}'),
              child: const Icon(Icons.chat_bubble_outline, size: 18),
            ),
          if (item.votes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Badge(
                label: Text('${item.votes.length}'),
                child: const Icon(Icons.how_to_vote_outlined, size: 18),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItineraryEditScreen(tripId: tripId, item: item)),
      ),
    );
  }
}
