import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/ad_provider.dart';
import '../../core/services/admob_service.dart';

class ChartDetailScreen extends ConsumerStatefulWidget {
  final String chartId;
  const ChartDetailScreen({Key? key, required this.chartId}) : super(key: key);

  @override
  ConsumerState<ChartDetailScreen> createState() => _ChartDetailScreenState();
}

class _ChartDetailScreenState extends ConsumerState<ChartDetailScreen> {
  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    AdMobService.loadInterstitial();
    AdMobService.loadRewardedAd();
    _loadChart();
  }

  Future<void> _loadChart() async {
    final doc = await FirebaseFirestore.instance.collection('charts').doc(widget.chartId).get();
    // increment views
    FirebaseFirestore.instance.collection('charts').doc(widget.chartId).update({
      'views': FieldValue.increment(1),
    });

    setState(() {
      data = doc.data();
      loading = false;
    });

    // handle interstitial logic
    ref.read(adProvider.notifier).incrementOpen();
    final adState = ref.read(adProvider);
    if (ref.read(adProvider.notifier).shouldShowInterstitial()) {
      await AdMobService.showInterstitial(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (data == null) return Scaffold(body: Center(child: Text('Not found')));

    final imageUrl = data!['imageUrl'] ?? '';
    final stockName = data!['stockName'] ?? '';
    final target = (data!['targetPrice'] as num?)?.toDouble() ?? 0;
    final pattern = data!['pattern'] ?? '';
    final timeframe = data!['timeframe'] ?? '';
    final chartDate = data!['chartDate'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(stockName),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3.0,
            ),
          ),
          Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCard('Date', chartDate),
                  _infoCard('Target', '₹${target.toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCard('Pattern', pattern),
                  _infoCard('Timeframe', timeframe),
                ],
              ),
              const SizedBox(height: 12),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }
}
