import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'home_provider.dart';
import 'widgets/chart_card.dart';
import '../home/widgets/premium_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartsAsync = ref.watch(chartsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BreakoutTrade'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: chartsAsync.when(
        data: (docs) {
          if (docs.isEmpty) {
            return Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timeline, size: 96, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('No charts yet', style: TextStyle(fontSize: 18)),
              ],
            ));
          }
          return RefreshIndicator(
            onRefresh: () async {
              // simple refresh — Riverpod stream updates automatically
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data()!;
                return ChartCard(
                  docId: doc.id,
                  stockName: data['stockName'] ?? '',
                  pattern: data['pattern'] ?? '',
                  timeframe: data['timeframe'] ?? '',
                  imageUrl: data['imageUrl'] ?? '',
                  targetPrice: (data['targetPrice'] as num?)?.toDouble() ?? 0,
                  uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  isPremium: data['isPremium'] ?? false,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: SizedBox(
        height: 56,
        child: Center(child: Text('Ad banner placeholder')),
      ),
    );
  }
}
