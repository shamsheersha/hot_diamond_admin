class AdminCredentials {
  final String username;
  final String password;

  AdminCredentials({required this.username, required this.password});

  // Convert model to a Map (for Shared Preferences)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
    };
  }

  // Convert Map to model
  factory AdminCredentials.fromMap(Map<String, dynamic> map) {
    return AdminCredentials(
      username: map['username'],
      password: map['password'],
    );
  }
}
