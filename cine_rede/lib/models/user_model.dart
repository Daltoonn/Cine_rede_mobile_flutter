class UserModel {
  String id;
  String email;
  String password;
  String username;
  String photoUrl;
  List<String> friends;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    this.username = '',
    this.photoUrl = '',
    this.friends = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'username': username,
      'photoUrl': photoUrl,
      'friends': friends.join(','),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      username: map['username'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      friends: map['friends'] != null && map['friends'] != ''
          ? map['friends'].toString().split(',')
          : [],
    );
  }
}
