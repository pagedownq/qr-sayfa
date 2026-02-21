class ScanHistoryItem {
  final String content;
  final DateTime timestamp;

  ScanHistoryItem({required this.content, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) =>
      ScanHistoryItem(
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
