class Account {
  String? id;
  String name;
  String? description;
  double balance;
  String createdAt;
  String updatedAt;
  AccountType type;

  Account({
    this.id,
    required this.name,
    this.description,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        balance: json["balance"].toDouble(),
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        type: getAccountType(json["type"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "balance": balance,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "type": getAccountType(type),
      };
}

getAccountType(type) {
  if (type is AccountType) {
    switch (type) {
      case AccountType.cash:
        return 'cash';
      case AccountType.bank:
        return 'bank';
      case AccountType.creditCard:
        return 'creditCard';
    }
  } else {
    switch (type) {
      case 'cash':
        return AccountType.cash;
      case 'bank':
        return AccountType.bank;
      case 'creditCard':
        return AccountType.creditCard;
    }
  }
}

enum AccountType {
  cash,
  bank,
  creditCard,
}
