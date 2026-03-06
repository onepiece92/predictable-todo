class ActivityLogModel {
  final int taskId;
  final String task;
  final int points;
  final String time;
  final String icon;
  /// 0 = no rating, 1–5 = mood rating from proof modal
  final int rating;

  const ActivityLogModel({
    required this.taskId,
    required this.task,
    required this.points,
    required this.time,
    required this.icon,
    this.rating = 0,
  });

  Map<String, dynamic> toJson() => {
    'taskId': taskId,
    'task': task,
    'points': points,
    'time': time,
    'icon': icon,
    'rating': rating,
  };

  factory ActivityLogModel.fromJson(Map<String, dynamic> j) => ActivityLogModel(
    taskId: j['taskId'] as int,
    task: j['task'] as String,
    points: j['points'] as int,
    time: j['time'] as String,
    icon: j['icon'] as String,
    rating: j['rating'] as int? ?? 0,
  );
}
