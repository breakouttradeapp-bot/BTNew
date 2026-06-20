import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChartListScreen extends StatefulWidget {
  const ChartListScreen({Key? key}) : super(key: key);

  @override
  State<ChartListScreen> createState() => _ChartListScreenState();
}

class _ChartListScreenState extends State<ChartListScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>> _stream() {
    return FirebaseFirestore.instance.collection('charts').orderBy('uploadedAt', descending: true).snapshots();
  }

  Future<void> _deleteChart(String id, String? imageUrl) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete chart?'),
        content: const Text('This will delete the chart and its image from storage.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance.collection('charts').doc(id).delete();
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          // ignore errors for storage delete
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chart deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Charts')), 
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('No charts uploaded'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = d.data();
              return ListTile(
                leading: data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty
                    ? Image.network(data['imageUrl'], width: 64, height: 64, fit: BoxFit.cover)
                    : const SizedBox(width: 64, height: 64, child: Icon(Icons.broken_image)),
                title: Text(data['stockName'] ?? '—'),
                subtitle: Text('${data['pattern'] ?? ''} • ${data['timeframe'] ?? ''}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    tooltip: 'Send Smart Notification',
                    icon: const Icon(Icons.campaign),
                    onPressed: () {
                      Navigator.pushNamed(context, '/send', arguments: {'chartId': d.id, 'prefill': data});
                    },
                  ),
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.pushNamed(context, '/chart_edit', arguments: d.id);
                    },
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteChart(d.id, data['imageUrl'] as String?),
                  ),
                ]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chart_edit'),
        child: const Icon(Icons.add),
        tooltip: 'Upload new chart',
      ),
    );
  }
}
