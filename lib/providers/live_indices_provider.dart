import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../stock.dart';

final liveIndicesProvider =
    StateNotifierProvider<LiveIndicesNotifier, Map<String, IndexData>>(
      (_) => LiveIndicesNotifier(),
    );

class LiveIndicesNotifier extends StateNotifier<Map<String, IndexData>> {
  LiveIndicesNotifier() : super({});

  void update(String name, IndexData data) {
    state = {...state, name: data};
  }

  void updateBatch(Map<String, IndexData> updates) {
    if (updates.isEmpty) return;

    state = {...state, ...updates};
  }
}
