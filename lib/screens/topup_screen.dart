import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'payment_method_screen.dart';

class TopUpScreen extends StatefulWidget {
  final String gameTitle;
  final String gameIcon;
  const TopUpScreen({required this.gameTitle, required this.gameIcon, Key? key})
    : super(key: key);

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController serverIdController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  int selectedItem = 0;
  int purchaseAmount = 1;
  int selectedPayment = 0;

  final List<Map<String, dynamic>> ucOptions = [
    {'amount': 60, 'price': 15200},
    {'amount': 120, 'price': 30400},
    {'amount': 180, 'price': 45600},
    {'amount': 660, 'price': 150900},
    {'amount': 720, 'price': 166100},
    {'amount': 780, 'price': 181300},
  ];

  final List<Map<String, dynamic>> diamondOptions = [
    {'amount': 86, 'price': 20000},
    {'amount': 172, 'price': 40000},
    {'amount': 257, 'price': 65000},
    {'amount': 344, 'price': 85000},
    {'amount': 568, 'price': 135000},
    {'amount': 875, 'price': 200000},
  ];

  final List<Map<String, dynamic>> paymentMethods = [
    {'icon': 'assets/dana.png', 'name': 'DANA'},
    {'icon': 'assets/bca.png', 'name': 'BCA'},
    {'icon': 'assets/gopay.png', 'name': 'Gopay'},
  ];

  Future<void> _orderNow() async {
    final userId = userIdController.text.trim();
    final serverId = serverIdController.text.trim();
    final whatsapp = whatsappController.text.trim();
    final isPubg = widget.gameTitle.toLowerCase() == 'pubg mobile';
    final isFreeFire = widget.gameTitle.toLowerCase() == 'free fire';
    final isGenshinImpact = widget.gameTitle.toLowerCase() == 'genshin impact';
    final isSingleIdGame = isPubg || isFreeFire || isGenshinImpact;
    final options = isPubg ? ucOptions : diamondOptions;
    final item = options[selectedItem];
    final payment = paymentMethods[selectedPayment]['name'];

    if (userId.isEmpty ||
        whatsapp.isEmpty ||
        (!isSingleIdGame && serverId.isEmpty)) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Semua data harus diisi!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    try {
      final response =
          await Supabase.instance.client.from('transactions').insert({
            'game': widget.gameTitle,
            'item': '${item['amount']} ${isPubg ? 'UC' : 'Diamonds'}',
            'amount': item['price'] * purchaseAmount,
            'status': 'pending',
            'user_id': userId,
            if (!isSingleIdGame) 'server_id': serverId,
            'payment': payment,
            'whatsapp': whatsapp,
          }).select();

      print('Supabase insert response: $response');
      final order = response.first;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => PaymentMethodScreen(
                paymentMethod: payment,
                amount: item['price'] * purchaseAmount,
                orderId: order['id'].toString(),
                game: widget.gameTitle,
                item: '${item['amount']} ${isPubg ? 'UC' : 'Diamonds'}',
              ),
        ),
      );
    } catch (e) {
      print('Order error: $e');
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Error'),
              content: Text('Gagal membuat pesanan: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPubg = widget.gameTitle.toLowerCase() == 'pubg mobile';
    final isFreeFire = widget.gameTitle.toLowerCase() == 'free fire';
    final isGenshinImpact = widget.gameTitle.toLowerCase() == 'genshin impact';
    final isSingleIdGame = isPubg || isFreeFire || isGenshinImpact;
    final options = isPubg ? ucOptions : diamondOptions;
    final itemLabel = isPubg ? 'UC' : 'Diamonds';

    return Scaffold(
      backgroundColor: const Color(0xFF5B5FE9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B5FE9),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        widget.gameIcon,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.gameTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Top Up $itemLabel',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Data Akun
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSingleIdGame ? 'Masukkan Data' : 'Masukkan Data Akun',
                      style: const TextStyle(
                        color: Color(0xFF5B5FE9),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPubg
                          ? 'Untuk menemukan ID Karakter Anda, masuk ke akun Anda di aplikasi. Klik avatar yang terletak di pojok kiri atas layar utama. Anda akan menemukan ID Karakter Anda tepat di bawah profil Anda.'
                          : isFreeFire || isGenshinImpact
                          ? 'Untuk menemukan ID Pemain Anda, klik gambar avatar Anda di pojok kiri atas layar Anda. ID Pemain Anda akan ditampilkan di bawah nama pengguna Anda.'
                          : 'Pastikan data yang dimasukkan benar',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isSingleIdGame)
                      TextField(
                        controller: userIdController,
                        decoration: InputDecoration(
                          hintText:
                              isFreeFire || isGenshinImpact
                                  ? 'Masukkan Player ID'
                                  : 'Masukkan User ID',
                          filled: true,
                          fillColor: const Color(0xFFF2F2F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: userIdController,
                              decoration: InputDecoration(
                                hintText: 'User id',
                                filled: true,
                                fillColor: const Color(0xFFF2F2F2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: serverIdController,
                              decoration: InputDecoration(
                                hintText: 'server id',
                                filled: true,
                                fillColor: const Color(0xFFF2F2F2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Pilih Nominal
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Nominal $itemLabel',
                      style: const TextStyle(
                        color: Color(0xFF5B5FE9),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.5,
                          ),
                      itemCount: options.length,
                      itemBuilder: (context, i) {
                        final option = options[i];
                        final selected = selectedItem == i;
                        return GestureDetector(
                          onTap: () => setState(() => selectedItem = i),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  selected
                                      ? const Color(0xFF5B5FE9)
                                      : const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  selected
                                      ? Border.all(
                                        color: Colors.deepPurple,
                                        width: 2,
                                      )
                                      : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isPubg
                                          ? Icons.monetization_on
                                          : Icons.diamond,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      option['amount'].toString(),
                                      style: TextStyle(
                                        color:
                                            selected
                                                ? Colors.white
                                                : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp. ${option['price']}',
                                  style: TextStyle(
                                    color:
                                        selected
                                            ? Colors.white70
                                            : Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Jumlah Pembelian
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Masukkan Jumlah Pembelian',
                      style: TextStyle(
                        color: Color(0xFF5B5FE9),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (purchaseAmount > 1)
                          setState(() => purchaseAmount--);
                      },
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        purchaseAmount.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => purchaseAmount++),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Metode Pembayaran
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Metode Pembayaran',
                      style: TextStyle(
                        color: Color(0xFF5B5FE9),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(paymentMethods.length, (i) {
                          final selected = selectedPayment == i;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: GestureDetector(
                              onTap: () => setState(() => selectedPayment = i),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      selected
                                          ? const Color(0xFF5B5FE9)
                                          : const Color(0xFFF2F2F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      selected
                                          ? Border.all(
                                            color: Colors.deepPurple,
                                            width: 2,
                                          )
                                          : null,
                                ),
                                child: Image.asset(
                                  paymentMethods[i]['icon'],
                                  width: 48,
                                  height: 32,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Kontak Whatsapp
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kontak Whatsapp',
                      style: TextStyle(
                        color: Color(0xFF5B5FE9),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: whatsappController,
                      decoration: InputDecoration(
                        hintText: '08xxxxxxxxxx',
                        filled: true,
                        fillColor: const Color(0xFFF2F2F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Order Button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB3B7F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _orderNow,
                  child: const Text(
                    'Order Sekarang',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
