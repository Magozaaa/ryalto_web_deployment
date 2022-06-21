class Reaction{
  int id;
  String reaction_type;
  dynamic user;
  dynamic post_id;
  dynamic comment_id;

  Reaction({
    this.id,
    this.reaction_type,
    this.user,
    this.post_id,
    this.comment_id,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
    id: json["id"],
    reaction_type: json["reaction_type"],
    user: json["user"],
    post_id: json["post_id"],
    comment_id: json["comment_id"],
  );


}