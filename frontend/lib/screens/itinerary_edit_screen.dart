import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/itinerary.dart';
import '../providers/trip_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class ItineraryEditScreen extends ConsumerStatefulWidget {
  final String tripId;
  final Itinerary? item;

  const ItineraryEditScreen({super.key, required this.tripId, this.item});

  @override
  ConsumerState<ItineraryEditScreen> createState() => _ItineraryEditScreenState();
}

class _ItineraryEditScreenState extends ConsumerState<ItineraryEditScreen> {
  late final _dayCtrl = TextEditingController(text: '${widget.item?.dayIndex ?? 1}');
  late final _timeCtrl = TextEditingController(text: widget.item?.time ?? '');
  late final _titleCtrl = TextEditingController(text: widget.item?.title ?? '');
  late final _costCtrl = TextEditingController(text: '${widget.item?.cost ?? 0}');
  late final _noteCtrl = TextEditingController(text: widget.item?.note ?? '');
  late ItineraryType _type = widget.item?.type ?? ItineraryType.sight;

  Future<void> _save() async {
    final data = {
      'dayIndex': int.tryParse(_dayCtrl.text) ?? 1,
      'time': _timeCtrl.text.isEmpty ? null : _timeCtrl.text,
      'title': _titleCtrl.text,
      'type': _type.name,
      'cost': int.tryParse(_costCtrl.text) ?? 0,
      'note': _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
    };

    if (widget.item != null) {
      await ref.read(itineraryNotifierProvider(widget.tripId).notifier).updateItem(
        widget.item!.copyWith(
          dayIndex: data['dayIndex'] as int,
          time: data['time'] as String?,
          title: data['title'] as String,
          type: _type,
          cost: data['cost'] as int,
          note: data['note'] as String?,
        ),
      );
      ref.read(socketServiceProvider).emitItineraryUpdate(widget.tripId, widget.item!.id, data);
    } else {
      final created = await ref.read(apiServiceProvider).createItinerary(widget.tripId, data);
      ref.read(socketServiceProvider).emitItineraryCreate(widget.tripId, created.toJson());
      ref.invalidate(itineraryNotifierProvider(widget.tripId));
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (widget.item == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(itineraryNotifierProvider(widget.tripId).notifier).delete(widget.item!.id);
      ref.read(socketServiceProvider).emitItineraryDelete(widget.tripId, widget.item!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _addComment() async {
    if (widget.item == null) return;
    final ctrl = TextEditingController();
    final content = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('发表评论'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: '写下你的想法...'), maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('发送')),
        ],
      ),
    );
    if (content != null && content.isNotEmpty) {
      final comment = await ref.read(apiServiceProvider).createComment(widget.item!.id, content);
      ref.read(socketServiceProvider).emitCommentAdded(widget.tripId, widget.item!.id, {
        'id': comment.id,
        'userId': comment.userId,
        'content': comment.content,
        'createdAt': comment.createdAt.toIso8601String(),
      });
      ref.invalidate(itineraryNotifierProvider(widget.tripId));
    }
  }

  Future<void> _vote() async {
    if (widget.item == null) return;
    final option = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('投票'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['想去', '不想去', '待定'].map((o) => ListTile(
            title: Text(o),
            onTap: () => Navigator.pop(ctx, o),
          )).toList(),
        ),
      ),
    );
    if (option != null) {
      final votes = await ref.read(apiServiceProvider).vote(widget.item!.id, option);
      ref.read(socketServiceProvider).emitVoteChanged(widget.tripId, widget.item!.id, votes.map((v) => v.toJson()).toList());
      ref.invalidate(itineraryNotifierProvider(widget.tripId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '编辑行程' : '新增行程'),
        actions: [
          if (isEdit)
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _delete),
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: '标题')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(controller: _dayCtrl, decoration: const InputDecoration(labelText: '第几天'), keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(controller: _timeCtrl, decoration: const InputDecoration(labelText: '时间')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ItineraryType>(
              value: _type,
              decoration: const InputDecoration(labelText: '类型'),
              items: ItineraryType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 12),
            TextField(controller: _costCtrl, decoration: const InputDecoration(labelText: '预算 (CNY)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _noteCtrl, decoration: const InputDecoration(labelText: '备注'), maxLines: 3),
            const SizedBox(height: 24),
            if (isEdit) ...[
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: _addComment, icon: const Icon(Icons.chat), label: const Text('评论'))),
                  const SizedBox(width: 12),
                  Expanded(child: OutlinedButton.icon(onPressed: _vote, icon: const Icon(Icons.how_to_vote), label: const Text('投票'))),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.item!.comments.isNotEmpty) ...[
                const Align(alignment: Alignment.centerLeft, child: Text('评论', style: TextStyle(fontWeight: FontWeight.bold))),
                ...widget.item!.comments.map((c) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.person_outline),
                  title: Text(c.user?.displayName ?? '某人'),
                  subtitle: Text(c.content),
                )),
              ],
              if (widget.item!.votes.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Align(alignment: Alignment.centerLeft, child: Text('投票', style: TextStyle(fontWeight: FontWeight.bold))),
                Wrap(
                  spacing: 8,
                  children: widget.item!.votes.map((v) => Chip(label: Text('${v.user?.displayName ?? '某人'}: ${v.option}'))).toList(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
