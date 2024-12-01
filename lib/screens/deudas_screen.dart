
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/deuda.dart';
import '../services/api_service.dart';

class DeudasScreen extends StatefulWidget {
  const DeudasScreen({Key? key}) : super(key: key);

  @override
  State<DeudasScreen> createState() => _DeudasScreenState();
}

class _DeudasScreenState extends State<DeudasScreen> {
  late Future<List<Deuda>> _deudasFuture;
  final _currencyFormat = NumberFormat.currency(
    symbol: 'RD\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _deudasFuture = _loadDeudas();
  }

  Future<List<Deuda>> _loadDeudas() {
    return Provider.of<ApiService>(context, listen: false).getDeudas();
  }

  Future<void> _refreshDeudas() async {
    setState(() {
      _deudasFuture = _loadDeudas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deudas'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDeudas,
        child: FutureBuilder<List<Deuda>>(
          future: _deudasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Error al cargar las deudas'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refreshDeudas,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final deudas = snapshot.data ?? [];

            if (deudas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 48, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text('No tienes deudas pendientes'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refreshDeudas,
                      child: const Text('Actualizar'),
                    ),
                  ],
                ),
              );
            }

            double totalDeuda = deudas
                .where((deuda) => !deuda.pagada)
                .fold(0, (sum, deuda) => sum + deuda.monto);

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    children: [
                      const Text(
                        'Deuda Total',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currencyFormat.format(totalDeuda),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: deudas.length,
                    itemBuilder: (context, index) {
                      final deuda = deudas[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: ListTile(
                          leading: Icon(
                            deuda.pagada ? Icons.check_circle : Icons.pending,
                            color: deuda.pagada ? Colors.green : Colors.orange,
                          ),
                          title: Text(_currencyFormat.format(deuda.monto)),
                          subtitle: Text(
                            'Actualizado: ${DateFormat('dd/MM/yyyy').format(deuda.fechaActualizacion)}',
                          ),
                          trailing: deuda.pagada
                              ? const Text(
                                  'PAGADO',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    // Implement payment logic
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Redirigiendo al portal de pagos...'),
                                      ),
                                    );
                                  },
                                  child: const Text('PAGAR'),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}