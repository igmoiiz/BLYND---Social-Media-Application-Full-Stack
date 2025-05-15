class User {
  String? name;
  String? email;
  String? password;
  int? phone;
  String? gender;
  int? age;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.gender,
    required this.age,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json["name"] as String,
    email: json["email"] as String,
    password: json["password"] as String,
    phone: json["phone"] as int,
    gender: json["gender"] as String,
    age: json["age"] as int,
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "password": password,
    "phone": phone,
    "gender": gender,
    "age": age,
  };
}
