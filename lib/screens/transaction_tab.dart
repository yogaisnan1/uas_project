import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionTab extends StatefulWidget {
  const TransactionTab({Key? key}) : super(key: key);

  @override
  _TransactionTabState createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab> {
  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final response = await Supabase.instance.client
        .from('transactions')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  String _gameIcon(String game) {
    switch (game.toLowerCase()) {
      case 'clash of clans':
        return 'assets/clash_of_clans.png';
      case 'mobile legends':
        return 'assets/mobile_legends.png';
      case 'pubg mobile':
        return 'assets/pubg_mobile.png';
      case 'free fire':
        return 'assets/free_fire.png';
      case 'genshin impact':
        return 'assets/genshin_impact.png';
      case 'arena breakout':
        return 'assets/arena_breakout.png';
      default:
        return 'assets/logo_controller.png';
    }
  }

  void _deleteTransaction(String id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this transaction?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      try {
        await Supabase.instance.client
            .from('transactions')
            .delete()
            .eq('id', id);
        print('Transaction deleted: $id');
        setState(() {});
      } catch (e) {
        print('Error deleting transaction: $e');
        // TODO: Show an error message to the user
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5B5FE9),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: const Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.history,
                          color: Color(0xFF5B5FE9),
                          size: 36,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Riwayat Transaksi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchTransactions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No transactions found.'));
                      }
                      final transactions = snapshot.data!;
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, i) {
                          final tx = transactions[i];
                          return _TransactionCardDynamic(
                            id: tx['id'].toString(),
                            icon: _gameIcon(tx['game'] ?? ''),
                            game: tx['game'] ?? '-',
                            item: tx['item'] ?? '-',
                            amount: tx['amount']?.toString() ?? '-',
                            status: tx['status'] ?? '-',
                            createdAt: tx['created_at'] ?? '',
                            deleteTransaction: _deleteTransaction,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCardDynamic extends StatelessWidget {
  final String id;
  final String icon;
  final String game;
  final String item;
  final String amount;
  final String status;
  final String createdAt;
  final Function(String) deleteTransaction;

  const _TransactionCardDynamic({
    Key? key,
    required this.id,
    required this.icon,
    required this.game,
    required this.item,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.deleteTransaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF5B5FE9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(icon, width: 48, height: 48, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  createdAt.toString(),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp. $amount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  color:
                      status.toLowerCase() == 'success'
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => deleteTransaction(id),
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
