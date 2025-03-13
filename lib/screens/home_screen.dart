import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_item.dart';
import '../widgets/search_bar.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "Tất cả";
  List<String> categories = ["Tất cả", "Điện thoại", "Laptop", "Phụ kiện"];

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // ✅ Đảm bảo truyền cả từ khóa tìm kiếm và danh mục vào `filteredProducts()`
    final products = productProvider.filteredProducts(_searchController.text, _selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: Text("🏠 Trang chủ"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, "/cart");
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: Colors.orange),
                  ),

                  SizedBox(height: 10),
                  Text(
                    'Xin chào, ${authProvider.currentUser?.username ?? "Người dùng"}',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: 5),
                  Text(
                    authProvider.currentUser?.email ?? "Chưa đăng nhập",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text("Tài khoản", style: TextStyle(fontSize: 18)),
              leading: Icon(Icons.account_circle),
              onTap: () {
                Navigator.pushNamed(context, '/account'); // Chuyển đến màn hình tài khoản
              },
            ),
            Divider(),
            ListTile(
              title: Text("Quản lý sản phẩm", style: TextStyle(fontSize: 18)),
              leading: Icon(Icons.shop),
              onTap: () {
                Navigator.pushNamed(context, '/products'); // Chuyển đến ProductScreen
              },
            ),
            ListTile(
              title: Text("📜 Lịch sử đơn hàng"),
              leading: Icon(Icons.history),
              onTap: () {
                Navigator.pushNamed(context, '/order_history');
              },
            ),
            Divider(),
            ListTile(
              title: Text("Đăng xuất", style: TextStyle(fontSize: 18, color: Colors.red)),
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              onTap: () async {
                await authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login'); // Quay về trang đăng nhập
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: CustomSearchBar(
              controller: _searchController,
              onSearch: (query) => setState(() {}), // Cập nhật danh sách khi tìm kiếm
            ),
          ),
          // 🔥 Bộ lọc danh mục sản phẩm
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              decoration: InputDecoration(
                labelText: "📂 Chọn danh mục",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? Center(child: Text("Không tìm thấy sản phẩm"))
                : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: products.length,
              itemBuilder: (ctx, index) => ProductItem(product: products[index]),
            ),
          ),
        ],
      ),
    );
  }
}
