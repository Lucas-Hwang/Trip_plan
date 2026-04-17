import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/itinerary.dart';
import '../providers/trip_provider.dart';

class BudgetTab extends ConsumerWidget {
  final String tripId;
  const BudgetTab({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itineraryNotifierProvider(tripId));

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (items) {
        final total = items.fold<int>(0, (s, i) => s + i.cost);
        final spent = items.where((i) => i.done).fold<int>(0, (s, i) => s + i.cost);
        final categories = <ItineraryType, int>{};
        for (final it in items) {
          categories[it.type] = (categories[it.type] ?? 0) + it.cost;
        }
        final typeLabels = {
          ItineraryType.food: '美食',
          ItineraryType.sight: '景点',
          ItineraryType.shopping: '购物',
          ItineraryType.relax: '放松',
          ItineraryType.transport: '交通',
        };
        final typeColors = {
          ItineraryType.food: Colors.orange,
          ItineraryType.sight: Colors.blue,
          ItineraryType.shopping: Colors.purple,
          ItineraryType.relax: Colors.green,
          ItineraryType.transport: Colors.grey,
        };

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _BudgetCard(label: '总预算', value: '¥$total', color: Colors.deepOrange),
                  _BudgetCard(label: '人均', value: '¥${(total / 4).round()}', color: Colors.blue),
                  _BudgetCard(label: '已花费', value: '¥$spent', color: Colors.green),
                  _BudgetCard(label: '剩余', value: '¥${total - spent}', color: Colors.red),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('分类统计', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      ...categories.entries.map((e) {
                        final pct = total == 0 ? 0.0 : e.value / total;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              SizedBox(width: 60, child: Text(typeLabels[e.key] ?? e.key.name)),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation(typeColors[e.key]),
                                  ),
                                ),
                              ),
                              SizedBox(width: 60, child: Text('¥${e.value}', textAlign: TextAlign.right)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _BudgetCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
