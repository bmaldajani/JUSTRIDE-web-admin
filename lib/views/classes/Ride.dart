class Ride {
  late String id;
  late String scooterId;
  late String userId;
  late String startStation;
  late String endStation;
  late DateTime startDate;
  late DateTime endDate;
  late double finalCost;
  late Duration duration;
  late int rating;

  Ride({
    required this.id,
    required this.scooterId,
    required this.userId,
    required this.startStation,
    this.endStation = '',
    required this.startDate,
    DateTime? endDate,
    this.finalCost = 0.0,
    Duration? duration,
    this.rating = 0,
  })  : this.endDate = endDate ?? DateTime.now(),
        this.duration = duration ?? Duration.zero;


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scooterId': scooterId,
      'userId': userId,
      'startStation': startStation,
      'endStation': endStation,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'finalCost': finalCost,
      'duration': duration.inSeconds,
      'rating': rating,
    };
  }

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'],
      scooterId: json['scooterId'],
      userId: json['userId'],
      startStation: json['startStation'],
      endStation: json['endStation'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      finalCost: json['finalCost']?.toDouble() ?? 0.0,
      duration: Duration(seconds: json['duration']),
      rating: json['rating'] ?? 0,
    );
  }
}
