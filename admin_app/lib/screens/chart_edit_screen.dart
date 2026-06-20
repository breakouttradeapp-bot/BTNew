import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChartEditScreen extends StatefulWidget {
  const ChartEditScreen({Key? key}) : super(key: key);

  @override
  State<ChartEditScreen> createState() => _ChartEditScreenState();
}

class _ChartEditScreenState extends State<ChartEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stockController = TextEditingController();
  final _dateController = TextEditingController();
  final _targetController = TextEditingController();
  final _upstoxController = TextEditingController();
  final _notesController = TextEditingController();
  String timeframe = 'Daily';
  String pattern = 'Cup & Handle';
  bool isPremium = false;
  bool isActive = true;
  Uint8List? _imageBytes;
  String? _existingImageUrl;
  bool _loading = false;
  String? _editingId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is String && _editingId == null) {
      _loadExisting(args);
    }
  }

  Future<void> _loadExisting(String id) async {
    setState(() => _loading = true);
    final doc = await FirebaseFirestore.instance.collection('charts').doc(id).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    _editingId = id;
    _stockController.text = data['stockName'] ?? '';
    _dateController.text = data['chartDate'] ?? '';
    _targetController.text = (data['targetPrice']?.toString() ?? '');
    _upstoxController.text = data['upstoxCode'] ?? '';
    _notesController.text = data['notes'] ?? '';
    timeframe = data['timeframe'] ?? 'Daily';
    pattern = data['pattern'] ?? pattern;
    isPremium = data['isPremium'] ?? false;
    isActive = data['isActive'] ?? true;
    _existingImageUrl = data['imageUrl'];
    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final res = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (res != null) {
      _imageBytes = await res.readAsBytes();
      setState(() {});
    }
  }

  Future<String?> _uploadImage(String docId) async {
    if (_imageBytes == null) return _existingImageUrl;
    final ref = FirebaseStorage.instance.ref().child('charts/$docId/chart.jpg');
    await ref.putData(_imageBytes!);
    return await ref.getDownloadURL();
  }

  Future<void> _saveChart() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_editingId == null) {
        final docRef = FirebaseFirestore.instance.collection('charts').doc();
        final url = await _uploadImage(docRef.id);
        await docRef.set({
          'stockName': _stockController.text.trim(),
          'chartDate': _dateController.text.trim(),
          'targetPrice': double.tryParse(_targetController.text) ?? 0,
          'pattern': pattern,
          'upstoxCode': _upstoxController.text.trim(),
          'notes': _notesController.text.trim(),
          'timeframe': timeframe,
          'isPremium': isPremium,
          'isActive': isActive,
          'imageUrl': url ?? '',
          'uploadedAt': FieldValue.serverTimestamp(),
          'views': 0,
        });
        // Ask whether to send a smart notification
        _askSendNotification(docRef.id);
      } else {
        final docRef = FirebaseFirestore.instance.collection('charts').doc(_editingId);
        String? url = _existingImageUrl;
        if (_imageBytes != null) {
          url = await _uploadImage(_editingId!);
        }
        await docRef.update({
          'stockName': _stockController.text.trim(),
          'chartDate': _dateController.text.trim(),
          'targetPrice': double.tryParse(_targetController.text) ?? 0,
          'pattern': pattern,
          'upstoxCode': _upstoxController.text.trim(),
          'notes': _notesController.text.trim(),
          'timeframe': timeframe,
          'isPremium': isPremium,
          'isActive': isActive,
          'imageUrl': url ?? '',
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chart updated')));
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _askSendNotification(String chartId) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send notification'),
        content: const Text('Do you want to send a notification about this new chart?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
        ],
      ),
    );
    if (res == true) {
      // navigate to send notification screen with prefill
      Navigator.pushNamed(context, '/send', arguments: {'chartId': chartId, 'prefill': {
        'stockName': _stockController.text.trim(),
        'chartDate': _dateController.text.trim(),
      }});
    }
  }

  @override
  void dispose() {
    _stockController.dispose();
    _dateController.dispose();
    _targetController.dispose();
    _upstoxController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editingId == null ? 'Upload Chart' : 'Edit Chart')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: 'Stock Name'), validator: (s) => s == null || s.isEmpty ? 'Required' : null),
                  const SizedBox(height: 8),
                  TextFormField(controller: _dateController, decoration: const InputDecoration(labelText: 'Chart Date')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _targetController, decoration: const InputDecoration(labelText: 'Target Price'), keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: pattern,
                    items: ['Cup & Handle', 'Triangle', 'Flag', 'Wedge', 'Resistance', 'Custom'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (v) => setState(() => pattern = v ?? pattern),
                    decoration: const InputDecoration(labelText: 'Pattern'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(controller: _upstoxController, decoration: const InputDecoration(labelText: 'Upstox code, optional')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes / Analysis'), maxLines: 4),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Text('Timeframe: '),
                    const SizedBox(width: 8),
                    ChoiceChip(label: const Text('Daily'), selected: timeframe == 'Daily', onSelected: (_) => setState(() => timeframe = 'Daily')),
                    const SizedBox(width: 8),
                    ChoiceChip(label: const Text('Weekly'), selected: timeframe == 'Weekly', onSelected: (_) => setState(() => timeframe = 'Weekly')),
                    const SizedBox(width: 8),
                    ChoiceChip(label: const Text('Monthly'), selected: timeframe == 'Monthly', onSelected: (_) => setState(() => timeframe = 'Monthly')),
                  ]),
                  SwitchListTile(title: const Text('Is Premium?'), value: isPremium, onChanged: (v) => setState(() => isPremium = v)),
                  SwitchListTile(title: const Text('Is Active?'), value: isActive, onChanged: (v) => setState(() => isActive = v)),
                  const SizedBox(height: 12),
                  _imageBytes == null && _existingImageUrl == null
                      ? ElevatedButton(onPressed: _pickImage, child: const Text('Select Chart Image'))
                      : Column(children: [
                          if (_imageBytes != null) Image.memory(_imageBytes!, height: 200),
                          if (_imageBytes == null && _existingImageUrl != null) Image.network(_existingImageUrl!, height: 200),
                          TextButton(onPressed: _pickImage, child: const Text('Change Image')),
                        ]),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _saveChart, child: Text(_editingId == null ? 'Upload Chart' : 'Update Chart')),
                ]),
              ),
            ),
    );
  }
}
