import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/premium_service.dart';
import '../utils/device_id_util.dart';

class PremiumState {
  final bool isPremium;
  final bool loading;
  PremiumState({required this.isPremium, this.loading = false});
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  PremiumNotifier() : super(PremiumState(isPremium: false, loading: true)) {
    _init();
  }

  final _service = PremiumService();

  Future<void> _init() async {
    final deviceId = await DeviceIdUtil.getDeviceId();
    final isPremium = await _service.isDevicePremium(deviceId);
    state = PremiumState(isPremium: isPremium, loading: false);
  }

  Future<void> refresh() async {
    state = PremiumState(isPremium: state.isPremium, loading: true);
    final deviceId = await DeviceIdUtil.getDeviceId();
    final isPremium = await _service.isDevicePremium(deviceId);
    state = PremiumState(isPremium: isPremium, loading: false);
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = await DeviceIdUtil.getDeviceId();
    await prefs.remove('premium_$deviceId');
    await refresh();
  }
}

final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>((ref) => PremiumNotifier());
