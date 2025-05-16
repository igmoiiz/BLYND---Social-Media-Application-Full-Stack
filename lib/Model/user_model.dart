class UserModel {
  String? name;
  String? email;
  String? password;
  int? phone;
  String? userName;
  int? age;
  String? profileImage;

  UserModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.userName,
    required this.age,
    required this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    name: json["name"] as String,
    email: json["email"] as String,
    password: json["password"] as String,
    phone: json["phone"] as int,
    userName: json["userName"] as String,
    age: json["age"] as int,
    profileImage: json["profileImage"] as String,
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "password": password,
    "phone": phone,
    "userName": userName,
    "age": age,
    "profileImage": profileImage,
  };
}
