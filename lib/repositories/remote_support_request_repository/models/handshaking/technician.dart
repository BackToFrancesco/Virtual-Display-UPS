class Technician {
  const Technician({required this.id});

  final int id;

  factory Technician.fromJson(Map<String, dynamic> json) =>
      Technician(id: json["id"]);

  Map<String, dynamic> toJson() => {"id": id, "isCustomer": false};
}
