import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/itinerary.dart';
import '../providers/trip_provider.dart';

class ChecklistTab extends ConsumerWidget {
  final String tripId;
  const ChecklistTab({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itineraryNotifierProvider(tripId));

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (items) {
        final filters = ['全部', '美食', '景点', '购物', '放松', '交通'];
        final filterTypes = [null, ItineraryType.food, ItineraryType.sight, ItineraryType.shopping, ItineraryType.relax, ItineraryType.transport];
        final activeFilter = ref.watch(_checklistFilterProvider);
        final type = filterTypes[filters.indexOf(activeFilter)];
        final filtered = type == null ? items : items.where((i) => i.type == type).toList();

        return Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: filters.length,
                itemBuilder: (_, i) {
                  final selected = filters[i] == activeFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filters[i]),
                      selected: selected,
                      onSelected: (_) => ref.read(_checklistFilterProvider.notifier).state = filters[i],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final it = filtered[i];
                  return CheckboxListTile(
                    value: it.done,
                    onChanged: (v) async {
                      final updated = it.copyWith(done: v ?? false);
                      await ref.read(itineraryNotifierProvider(tripId).notifier).updateItem(updated);
                    },
                    title: Text(it.title, style: TextStyle(decoration: it.done ? TextDecoration.lineThrough : null)),
                    subtitle: Text('第 ${it.dayIndex} 天 · ${it.time ?? '全天'}'),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

final _checklistFilterProvider = StateProvider<String>((ref) => '全部');
