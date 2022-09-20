class Account {
  String? id;
  String name;
  String? description;
  double balance;
  String createdAt;
  String updatedAt;

  Account({
    this.id,
    required this.name,
    this.description,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        balance: json["balance"].toDouble(),
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "balance": balance,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
      };
}
