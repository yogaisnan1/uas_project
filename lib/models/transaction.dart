class Transaction {
  final String id;
  final String game;
  final String item;
  final int amount;
  final String status;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.game,
    required this.item,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      game: map['game'] ?? '',
      item: map['item'] ?? '',
      amount:
          map['amount'] is int
              ? map['amount']
              : int.tryParse(map['amount'].toString()) ?? 0,
      status: map['status'] ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
