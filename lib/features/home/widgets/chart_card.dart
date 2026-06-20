import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/providers/ad_provider.dart';
import '../../../core/providers/premium_provider.dart';
import '../../../core/utils/share_util.dart';

class ChartCard extends ConsumerStatefulWidget {
  final String docId;
  final String stockName;
  final String pattern;
  final String timeframe;
  final String imageUrl;
  final double targetPrice;
  final DateTime uploadedAt;
  final bool isPremium;

  const ChartCard({
    Key? key,
    required this.docId,
    required this.stockName,
    required this.pattern,
    required this.timeframe,
    required this.imageUrl,
    required this.targetPrice,
    required this.uploadedAt,
    required this.isPremium,
  }) : super(key: key);

  @override
  ConsumerState<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends ConsumerState<ChartCard> {
  bool unlocked = false;

  @override
  void initState() {
    super.initState();
    _checkUnlocked();
  }

  Future<void> _checkUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getBool('unlocked_chart_${widget.docId}') ?? false;
    setState(() => unlocked = val);
  }

  Future<void> _unlockWithAd() async {
    // Use AdMob rewarded flow; for now we simulate with AdMobService.showRewardedAd
    // The AdMobService will call back to unlock when reward granted.
    ref.read(adProvider.notifier).incrementOpen();
    // The actual rewarded ad display is handled by AdMobService elsewhere in UI flow.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('unlocked_chart_${widget.docId}', true);
    setState(() => unlocked = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chart unlocked')));
  }

  @override
  Widget build(BuildContext context) {
    final relative = timeago.format(widget.uploadedAt);
    final premiumState = ref.watch(premiumProvider);
    final isPremiumUser = premiumState.isPremium;
    final showLocked = widget.isPremium && !isPremiumUser && !unlocked;

    return Card(
      child: InkWell(
        onTap: () async {
          if (showLocked) {
            _showLockedDialog();
            return;
          }
          Navigator.pushNamed(context, '/chart_detail', arguments: widget.docId);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (c, s) => Container(color: Colors.grey[200]),
                    errorWidget: (c, s, e) => const Icon(Icons.broken_image),
                  ),
                  if (showLocked)
                    Container(
                      color: Colors.white.withOpacity(0.6),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.lock, size: 48, color: Colors.black45),
                            SizedBox(height: 8),
                            Text('Premium', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                    child: Text(widget.stockName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                    child: Text(widget.pattern),
                  ),
                  const Spacer(),
                  Text(widget.timeframe, style: const TextStyle(color: Colors.grey)),
                ]),
                const SizedBox(height: 8),
                Text('Target: ₹${widget.targetPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.green)),
                const SizedBox(height: 6),
                Text('$relative • Notes preview...', maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.remove_red_eye, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  const Text('123', style: TextStyle(color: Colors.grey)),
                  const Spacer(),
                  IconButton(onPressed: () => ShareUtil.shareImageFromUrl(widget.imageUrl, 'Check out ${widget.stockName} breakout chart!'), icon: const Icon(Icons.share)),
                ]),
              ]),
            )
          ],
        ),
      ),
    );
  }

  void _showLockedDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Premium Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('This chart is available for premium users. You can upgrade or watch an ad to unlock this chart.'),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ElevatedButton(onPressed: () { Navigator.pop(ctx); Navigator.pushNamed(context, '/premium'); }, child: const Text('Upgrade'))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton(onPressed: () { Navigator.pop(ctx); _unlockWithAd(); }, child: const Text('Watch Ad'))),
            ])
          ]),
        ),
      ),
    );
  }
}
