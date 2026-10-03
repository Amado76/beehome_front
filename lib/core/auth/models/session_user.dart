class SessionUser {
  const SessionUser(this.id, this.name, this.email);

  final String id;
  final String name;
  final String email;

  factory SessionUser.fromJson(Object? json) {
    if (json is! Map<String, Object?> ||
        json['id'] is! String ||
        json['name'] is! String ||
        json['email'] is! String) {
      throw const FormatException('Invalid current user response.');
    }
    return SessionUser(
      json['id']! as String,
      json['name']! as String,
      json['email']! as String,
    );
  }
}
