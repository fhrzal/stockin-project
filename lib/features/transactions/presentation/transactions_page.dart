import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/transaction_model.dart';
import '../provider/transaction_provider.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.read<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: const InputDecoration(
                labelText: 'Filter Transaksi',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'all',
                  child: Text('Semua'),
                ),
                DropdownMenuItem(
                  value: 'in',
                  child: Text('Barang Masuk'),
                ),
                DropdownMenuItem(
                  value: 'out',
                  child: Text('Barang Keluar'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value ?? 'all';
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<TransactionModel>>(
              stream: transactionProvider.getTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(
                    message: 'Mengambil riwayat transaksi...',
                  );
                }

                if (snapshot.hasError) {
                  return const ErrorStateWidget(
                    message: 'Gagal mengambil data transaksi.',
                  );
                }

                final transactions = snapshot.data ?? [];

                List<TransactionModel> filteredTransactions;
                if (_selectedFilter == 'all') {
                  filteredTransactions = transactions;
                } else {
                  filteredTransactions = transactions
                      .where((trx) => trx.type == _selectedFilter)
                      .toList();
                }

                if (transactions.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.receipt_long_outlined,
                    title: 'Belum Ada Transaksi',
                    subtitle: 'Riwayat transaksi akan muncul setelah ada barang masuk atau keluar.',
                  );
                }

                if (filteredTransactions.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.filter_alt_off,
                    title: 'Tidak Ada Data',
                    subtitle: 'Tidak ada transaksi yang cocok dengan filter ini.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTransactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final trx = filteredTransactions[index];
                    final isIn = trx.type == 'in';

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          child: Icon(
                            isIn ? Icons.arrow_downward : Icons.arrow_upward,
                          ),
                        ),
                        title: Text(
                          trx.itemName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tipe: ${isIn ? "Masuk" : "Keluar"}'),
                              Text('Jumlah: ${trx.quantity}'),
                              Text('Keterangan: ${trx.description}'),
                            ],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isIn
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isIn ? 'IN' : 'OUT',
                            style: TextStyle(
                              color: isIn ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }
}