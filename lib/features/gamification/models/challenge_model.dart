enum ChallengeType { earlyBird, tripleThreat, healthHero }

class ChallengeModel {
  final int id;
  final ChallengeType type;
  final String title;
  final String desc;
  final int reward;
  final String icon;
  final bool done;

  const ChallengeModel({
    required this.id,
    required this.type,
    required this.title,
    required this.desc,
    required this.reward,
    required this.icon,
    required this.done,
  });

  ChallengeModel copyWith({
    int? id,
    ChallengeType? type,
    String? title,
    String? desc,
    int? reward,
    String? icon,
    bool? done,
  }) =>
      ChallengeModel(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        desc: desc ?? this.desc,
        reward: reward ?? this.reward,
        icon: icon ?? this.icon,
        done: done ?? this.done,
      );
}
