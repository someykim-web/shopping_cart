import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// ================= WARNA =================
const Color kPrimary = Color(0xFF1565F0);
const Color kPrimaryLight = Color(0xFFEAF2FF);
const Color kBackground = Color(0xFFF4F6FA);
const Color kTextGrey = Color(0xFF8A8F99);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Cart',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
        scaffoldBackgroundColor: kBackground,
      ),
      // Kalau dijalankan di layar lebar (browser / DartPad),
      // aplikasi ditampilkan di dalam bingkai HP seperti mockup.
      builder: (context, child) => PhoneFrame(child: child!),
      home: const CartPage(),
    );
  }
}

// ================= MODEL =================
class Product {
  final String name;
  final String brand;
  final int price;
  final String imageUrl;
  final IconData fallbackIcon;
  int likes;
  bool isLiked;
  int qty;

  Product({
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.likes,
    this.isLiked = false,
    this.qty = 1,
  });
}

// Format angka ke Rupiah: 8100000 -> Rp 8.100.000
String formatRupiah(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

// ================= HALAMAN UTAMA (StatefulWidget) =================
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<Product> products = [
    Product(
      name: 'Wireless Headphone',
      brand: 'Sony WH-CH520',
      price: 350000,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/Headphones_1.jpg/330px-Headphones_1.jpg',
      fallbackIcon: Icons.headphones,
      likes: 12,
    ),
    Product(
      name: 'Laptop ASUS Vivobook',
      brand: 'ASUS',
      price: 7500000,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Laptop_PC.jpg/330px-Laptop_PC.jpg',
      fallbackIcon: Icons.laptop,
      likes: 8,
    ),
    Product(
      name: 'Wireless Mouse',
      brand: 'Logitech M330',
      price: 250000,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/A_black_wireless_computer_mouse.jpg/330px-A_black_wireless_computer_mouse.jpg',
      fallbackIcon: Icons.mouse,
      likes: 5,
    ),
  ];

  int? selectedIndex; // produk yang dipilih lewat Tap
  String? toastProduct; // nama produk untuk notifikasi Long Press
  Timer? _toastTimer;
  int navIndex = 0;

  // ---------- Perhitungan (jumlah barang & total harga) ----------
  int get totalItems => products.fold(0, (sum, p) => sum + p.qty);
  int get totalPrice => products.fold(0, (sum, p) => sum + p.price * p.qty);

  // ---------- Interaksi 1: TAP -> produk dipilih (highlight/border berubah) ----------
  void _onTap(int i) {
    setState(() {
      selectedIndex = selectedIndex == i ? null : i;
    });
  }

  // ---------- Interaksi 2: DOUBLE TAP -> jumlah like bertambah ----------
  void _onDoubleTap(int i) {
    setState(() {
      final p = products[i];
      p.isLiked = !p.isLiked;
      p.likes += p.isLiked ? 1 : -1;
    });
  }

  // ---------- Interaksi 3: LONG PRESS -> pesan informasi ditampilkan ----------
  void _onLongPress(int i) {
    _toastTimer?.cancel();
    setState(() {
      selectedIndex = i;
      toastProduct = products[i].name;
    });
    _toastTimer = Timer(const Duration(seconds: 3), _closeToast);
  }

  void _closeToast() {
    _toastTimer?.cancel();
    if (mounted) setState(() => toastProduct = null);
  }

  // ---------- Interaksi tambahan: ubah jumlah barang ----------
  void _changeQty(int i, int delta) {
    setState(() {
      final newQty = products[i].qty + delta;
      if (newQty >= 0) products[i].qty = newQty;
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                  itemCount: products.length,
                  itemBuilder: (context, i) => _buildProductCard(i),
                ),
              ),
              _buildSummary(),
            ],
          ),
          _buildToast(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: kPrimary,
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 14, 12, 16),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Cart',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Belanja lebih mudah setiap hari',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(int i) {
    final p = products[i];
    final selected = selectedIndex == i;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: selected ? kPrimaryLight : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? kPrimary : const Color(0xFFE6E9EF),
          width: selected ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // GestureDetector: Tap, Double Tap, dan Long Press pada produk.
          // Tombol +/- sengaja di luar area ini supaya klik cepat pada
          // tombol tidak terbaca sebagai Double Tap.
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _onTap(i),
              onDoubleTap: () => _onDoubleTap(i),
              onLongPress: () => _onLongPress(i),
              child: Row(
                children: [
                  _buildProductImage(p),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(p.brand,
                            style: const TextStyle(
                                color: kTextGrey, fontSize: 12)),
                        const SizedBox(height: 6),
                        Text(formatRupiah(p.price),
                            style: const TextStyle(
                                color: kPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(height: 10),
                        // Ikon hati juga bisa diklik langsung untuk like
                        GestureDetector(
                          onTap: () => _onDoubleTap(i),
                          child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                p.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey(p.isLiked),
                                color: p.isLiked
                                    ? const Color(0xFFE53935)
                                    : Colors.black87,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('${p.likes}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Kontrol jumlah barang
          Row(
            children: [
              _qtyButton(Icons.remove, () => _changeQty(i, -1), false),
              SizedBox(
                width: 30,
                child: Text('${p.qty}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              _qtyButton(Icons.add, () => _changeQty(i, 1), true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(Product p) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        p.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))),
        errorBuilder: (context, error, stack) =>
            Icon(p.fallbackIcon, size: 44, color: Colors.black87),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap, bool filled) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: filled ? kPrimary : kPrimaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: filled ? Colors.white : kPrimary),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6E9EF))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total ($totalItems produk)',
                    style: const TextStyle(fontSize: 12, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(formatRupiah(totalPrice),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kPrimary)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: totalItems == 0
                ? null
                : () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                            'Checkout $totalItems produk, total ${formatRupiah(totalPrice)}'),
                      ),
                    ),
            child: const Text('Checkout',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // Notifikasi di bagian atas (muncul saat Long Press)
  Widget _buildToast() {
    final visible = toastProduct != null;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      left: 12,
      right: 12,
      top: visible ? MediaQuery.of(context).padding.top + 8 : -120,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: visible ? 1 : 0,
        child: Material(
          color: const Color(0xFF1F2430),
          elevation: 6,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: Color(0xFF34C759), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Produk dipilih!',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('${toastProduct ?? ''} telah dipilih.',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: _closeToast,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: navIndex,
      onTap: (i) => setState(() => navIndex = i),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: kPrimary,
      unselectedItemColor: kTextGrey,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      items: [
        const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), label: 'Beranda'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined), label: 'Kategori'),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text('$totalItems'),
            isLabelVisible: totalItems > 0,
            backgroundColor: const Color(0xFFE53935),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          label: 'Keranjang',
        ),
        const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Akun'),
      ],
    );
  }
}

// ================= BINGKAI HP (hanya di layar lebar) =================
class PhoneFrame extends StatelessWidget {
  final Widget child;
  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Di HP / emulator sungguhan, tampilkan apa adanya tanpa bingkai.
    if (size.width < 500) return child;

    const double phoneW = 390;
    final double phoneH = (size.height - 32).clamp(560.0, 844.0).toDouble();

    return ColoredBox(
      color: const Color(0xFFDCE6F7),
      child: Center(
        child: Container(
          width: phoneW + 20,
          height: phoneH + 20,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B1F),
            borderRadius: BorderRadius.circular(52),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 30,
                  offset: Offset(0, 12)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(42),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: Size(phoneW, phoneH),
                padding: const EdgeInsets.only(top: 44),
                viewPadding: const EdgeInsets.only(top: 44),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: child),
                  const Positioned(
                      top: 0, left: 0, right: 0, child: _StatusBar()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dynamic island
            Container(
              width: 110,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                children: [
                  Text('9:41',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Spacer(),
                  Icon(Icons.signal_cellular_alt,
                      color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Icon(Icons.wifi, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Icon(Icons.battery_full, color: Colors.white, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
