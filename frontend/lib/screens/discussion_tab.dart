import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/itinerary.dart';
import '../providers/trip_provider.dart';
import '../services/api_service.dart';

class DiscussionTab extends ConsumerWidget {
  final String tripId;
  const DiscussionTab({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itineraryNotifierProvider(tripId));

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (items) {
        final withComments = items.where((i) => i.comments.isNotEmpty || i.votes.isNotEmpty).toList();
        if (withComments.isEmpty) {
          return const Center(child: Text('暂无讨论，去行程页评论或投票吧'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: withComments.length,
          itemBuilder: (_, i) {
            final it = withComments[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(it.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (it.comments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...it.comments.take(3).map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('${c.user?.displayName ?? '某人'}: ${c.content}', style: const TextStyle(fontSize: 13)),
                      )),
                    ],
                    if (it.votes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: it.votes.map((v) => Chip(
                          label: Text('${v.user?.displayName ?? '某人'}: ${v.option}', style: const TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
