class User {
  final String id;
  final String email;
  final String name;
  final String password; 
  final int phoneNumber;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.password,
    required this.phoneNumber,
  });

  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      password: json['password'] as String,
      phoneNumber: json['phoneNumber'] is int
          ? json['phoneNumber'] as int
          : int.parse(json['phoneNumber'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'email': email,
        'name': name,
        'password': password,
        'phoneNumber': phoneNumber,
      };
}
