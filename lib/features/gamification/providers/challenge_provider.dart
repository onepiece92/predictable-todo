import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_model.dart';
import '../../tasks/models/task_model.dart';
import '../../../core/data/seed_data.dart';

class ChallengeNotifier extends StateNotifier<List<ChallengeModel>> {
  ChallengeNotifier() : super(SeedData.challenges);

  int get doneCount => state.where((c) => c.done).length;
  bool get allDone => state.every((c) => c.done);

  void onTaskCompleted(TaskModel task, int completedInRow) {
    final hour = DateTime.now().hour;
    state = state.map((ch) {
      if (ch.done) return ch;
      switch (ch.type) {
        case ChallengeType.earlyBird:
          return hour < 8 ? ch.copyWith(done: true) : ch;
        case ChallengeType.tripleThreat:
          return completedInRow >= 3 ? ch.copyWith(done: true) : ch;
        case ChallengeType.healthHero:
          return task.category == TaskCategory.health ? ch.copyWith(done: true) : ch;
      }
    }).toList();
  }

  void reset() {
    state = SeedData.challenges;
  }
}

final challengeProvider =
    StateNotifierProvider<ChallengeNotifier, List<ChallengeModel>>(
  (ref) => ChallengeNotifier(),
);
