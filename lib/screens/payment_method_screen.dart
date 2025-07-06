import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatelessWidget {
  final String paymentMethod;
  final int amount;
  final String orderId;
  final String game;
  final String item;

  const PaymentMethodScreen({
    Key? key,
    required this.paymentMethod,
    required this.amount,
    required this.orderId,
    required this.game,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: const Color(0xFF5B5FE9),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Icon(
                Icons.account_balance_wallet,
                size: 64,
                color: Color(0xFF5B5FE9),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Order ID: $orderId',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Game: $game'),
            Text('Item: $item'),
            const SizedBox(height: 16),
            Text(
              'Metode Pembayaran:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              paymentMethod,
              style: const TextStyle(fontSize: 18, color: Color(0xFF5B5FE9)),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Pembayaran:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Rp. $amount',
              style: const TextStyle(fontSize: 22, color: Colors.green),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B5FE9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed('/home', arguments: 2);
                },
                child: const Text('Saya Sudah Bayar (Lihat Riwayat)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
