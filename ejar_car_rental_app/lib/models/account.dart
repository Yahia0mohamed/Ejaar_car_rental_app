class Account {
  final String id;
  final String username;
  final String email;
  final String imageBase64;

  Account({
    required this.id,
    required this.username,
    required this.email,
    required this.imageBase64,
  });

  factory Account.fromMap(String id, Map<String, dynamic> data) {
    return Account(
      id: id,
      username: data['username'],
      email: data['email'],
      imageBase64: data['imageBase64'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'imageBase64': imageBase64,
    };
  }
}
