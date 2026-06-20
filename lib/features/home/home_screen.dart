import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'home_provider.dart';
import 'widgets/chart_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String filter = 'All';
  String search = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search stock or pattern', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            onChanged: (v) => setState(() => search = v.trim().toLowerCase()),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: ['All', 'Daily', 'Weekly', 'Monthly', 'Free', 'Premium'].map((e) {
              final selected = filter == e;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(label: Text(e), selected: selected, onSelected: (_) => setState(() => filter = e)),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: chartsAsync.when(
            data: (docs) {
              var filtered = docs;
              if (filter == 'Daily' || filter == 'Weekly' || filter == 'Monthly') {
                filtered = filtered.where((d) => (d.data()['timeframe'] ?? '').toString().toLowerCase() == filter.toLowerCase()).toList();
              }
              if (filter == 'Free') {
                filtered = filtered.where((d) => (d.data()['isPremium'] ?? false) == false).toList();
              }
              if (filter == 'Premium') {
                filtered = filtered.where((d) => (d.data()['isPremium'] ?? false) == true).toList();
              }
              if (search.isNotEmpty) {
                filtered = filtered.where((d) {
                  final data = d.data();
                  final name = (data['stockName'] ?? '').toString().toLowerCase();
                  final pattern = (data['pattern'] ?? '').toString().toLowerCase();
                  return name.contains(search) || pattern.contains(search);
                }).toList();
              }

              if (filtered.isEmpty) return const Center(child: Text('No charts found'));

              return RefreshIndicator(
                onRefresh: () async {},
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
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
            loading: () => ListView.builder(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, __) => const SizedBox(height: 200, child: Card(child: Center(child: CircularProgressIndicator()))),
              itemCount: 6,
            ),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ),
      ]),
      bottomNavigationBar: SizedBox(
        height: 56,
        child: Center(child: Text('Ad banner placeholder')),
      ),
    );
  }
}
