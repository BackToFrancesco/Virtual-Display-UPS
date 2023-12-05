class User {
  final int id;
  final String name;
  final String surname;
  final String email;
  final String phoneNumber;

  const User(
      {required this.id,
      required this.name,
      required this.surname,
      required this.email,
      required this.phoneNumber});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        surname: json["surname"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "surname": surname,
        "email": email,
        "phoneNumber": phoneNumber,
        "isCustomer": true
      };

  factory User.fromRestrictedJson(Map<String, dynamic> json) =>
      User(id: json["id"], name: "", surname: "", email: "", phoneNumber: "");

  Map<String, dynamic> toRestrictedJson() => {"id": id, "isCustomer": true};
}
