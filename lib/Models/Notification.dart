class NotificationModel{
  int id;
  int type_id;
  dynamic notification_type;
  dynamic message;
  dynamic created_at;
  dynamic metadata;
  dynamic status;

  NotificationModel({
    this.id,
    this.type_id,
    this.notification_type,
    this.message,
    this.created_at,
    this.metadata,
    this.status,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id: json["id"],
    type_id: json["type_id"],
    notification_type: json["notification_type"],
    message: json["message"],
    created_at: json["created_at"],
    metadata: json["metadata"],
    status: json["status"],
  );


}