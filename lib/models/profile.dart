class Profile {
  String userid;
  String name;
  String email;
  String pfpURL;

  Profile({
    required this.userid,
    required this.name,
    required this.email,
    required this.pfpURL,
  });

  Profile.fromJson(Map<String, Object?> json)
      : this(
          userid: json['userid']! as String,
          name: json['name']! as String,
          email: json['email']! as String,
          pfpURL: json['pfpURL']! as String,
        );

  Profile copyWith({
    String? userid,
    String? name,
    String? email,
    String? pfpURL,
  }) {
    return Profile(
      userid: userid ?? this.userid,
      name: name ?? this.name,
      email: email ?? this.email,
      pfpURL: pfpURL ?? this.pfpURL,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'userid': userid,
      'name': name,
      'email': email,
      'pfpURL': pfpURL,
    };
  }
}
