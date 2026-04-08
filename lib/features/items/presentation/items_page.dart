import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/item_model.dart';
import '../../transactions/presentation/stock_in_page.dart';
import '../../transactions/presentation/stock_out_page.dart';
import '../provider/item_provider.dart';
import 'add_item_page.dart';
import 'edit_item_page.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final itemProvider = context.read<ItemProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Barang'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari nama barang atau SKU...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ItemModel>>(
              stream: itemProvider.getItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(
                    message: 'Mengambil data barang...',
                  );
                }

                if (snapshot.hasError) {
                  return const ErrorStateWidget(
                    message: 'Terjadi kesalahan saat mengambil data barang.',
                  );
                }

                final items = snapshot.data ?? [];

                final filteredItems = items.where((item) {
                  final name = item.name.toLowerCase();
                  final sku = item.sku.toLowerCase();
                  return name.contains(_searchQuery) ||
                      sku.contains(_searchQuery);
                }).toList();

                if (items.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    title: 'Belum Ada Data Barang',
                    subtitle: 'Tambahkan barang pertama untuk mulai monitoring stok.',
                  );
                }

                if (filteredItems.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.search_off,
                    title: 'Barang Tidak Ditemukan',
                    subtitle: 'Coba gunakan kata kunci lain.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final isLowStock = item.stock <= item.minStock;

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SKU: ${item.sku}'),
                              Text('Stok: ${item.stock} ${item.unit}'),
                              Text('Minimum: ${item.minStock}'),
                              const SizedBox(height: 6),
                              if (isLowStock)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Stok Minimum',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditItemPage(item: item),
                                ),
                              );
                            } else if (value == 'stock_in') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StockInPage(item: item),
                                ),
                              );
                            } else if (value == 'stock_out') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StockOutPage(item: item),
                                ),
                              );
                            } else if (value == 'delete') {
                              final success = await context
                                  .read<ItemProvider>()
                                  .deleteItem(item.id);

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Barang berhasil dihapus'
                                        : 'Gagal menghapus barang',
                                  ),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'stock_in',
                              child: Text('Barang Masuk'),
                            ),
                            PopupMenuItem(
                              value: 'stock_out',
                              child: Text('Barang Keluar'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddItemPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}