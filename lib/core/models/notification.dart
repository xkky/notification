class AppNotification {
  final String id;

  final String title;

  final String body;

  final String type;

  final String sound;

  AppNotification({
    required this.id,

    required this.title,

    required this.body,

    required this.type,

    required this.sound,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json["id"],

      title: json["title"],

      body: json["body"],

      type: json["type"],

      sound: json["sound"] ?? "default",
    );
  }
}
