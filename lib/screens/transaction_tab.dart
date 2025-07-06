import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionTab extends StatelessWidget {
  const TransactionTab({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                    return Center(child: Text('Error: \\${snapshot.error}'));
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
                        icon: _gameIcon(tx['game'] ?? ''),
                        game: tx['game'] ?? '-',
                        item: tx['item'] ?? '-',
                        amount: tx['amount']?.toString() ?? '-',
                        status: tx['status'] ?? '-',
                        createdAt: tx['created_at'] ?? '',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCardDynamic extends StatelessWidget {
  final String icon;
  final String game;
  final String item;
  final String amount;
  final String status;
  final String createdAt;
  const _TransactionCardDynamic({
    required this.icon,
    required this.game,
    required this.item,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

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
        ],
      ),
    );
  }
}
