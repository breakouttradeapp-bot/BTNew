import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdState {
  final int opens;
  AdState(this.opens);
}

class AdNotifier extends StateNotifier<AdState> {
  AdNotifier() : super(AdState(0));

  void incrementOpen() {
    state = AdState(state.opens + 1);
  }

  bool shouldShowInterstitial({int frequency = 5}) {
    return (state.opens % frequency) == 0 && state.opens != 0;
  }
}

final adProvider = StateNotifierProvider<AdNotifier, AdState>((ref) => AdNotifier());
