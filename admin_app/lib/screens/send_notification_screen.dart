import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({Key? key}) : super(key: key);

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _serverKeyController = TextEditingController();
  String target = 'all';
  String? selectedChartId;

  Future<void> _send() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final serverKey = _serverKeyController.text.trim();
    if (title.isEmpty || body.isEmpty) return;

    // Save to Firestore notifications collection
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'body': body,
      'chartId': selectedChartId,
      'target': target,
      'sentAt': FieldValue.serverTimestamp(),
    });

    if (serverKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved notification; provide server key to send push.')));
      return;
    }

    final topic = target == 'all' ? '/topics/all_users' : (target == 'premium' ? '/topics/premium_users' : '/topics/free_users');

    final payload = {
      'to': topic,
      'priority': 'high',
      'notification': {
        'title': title,
        'body': body,
      },
      'data': {
        'chartId': selectedChartId ?? '',
      }
    };

    try {
      final res = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'key=$serverKey'},
          body: jsonEncode(payload));

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification sent')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('FCM send failed: ${res.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('FCM send error: $e')));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _serverKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['chartId'] != null) {
      selectedChartId = args['chartId'] as String?;
      if (args['prefill'] is Map) {
        final pre = args['prefill'] as Map;
        _titleController.text = pre['stockName'] ?? '';
        _bodyController.text = pre['chartDate'] ?? '';
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 8),
          TextField(controller: _bodyController, decoration: const InputDecoration(labelText: 'Message'), maxLines: 3),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: target,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Users')),
              DropdownMenuItem(value: 'premium', child: Text('Premium Only')),
              DropdownMenuItem(value: 'free', child: Text('Free Only')),
            ],
            onChanged: (v) => setState(() => target = v ?? 'all'),
            decoration: const InputDecoration(labelText: 'Target'),
          ),
          const SizedBox(height: 8),
          TextField(controller: _serverKeyController, decoration: const InputDecoration(labelText: 'FCM Server Key (leave empty to skip sending)')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _send, child: const Text('Send Notification')),
        ]),
      ),
    );
  }
}
