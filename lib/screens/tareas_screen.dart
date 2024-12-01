
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/tarea.dart';
import '../services/api_service.dart';

class TareasScreen extends StatefulWidget {
  const TareasScreen({Key? key}) : super(key: key);

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  late Future<List<Tarea>> _tareasFuture;

  @override
  void initState() {
    super.initState();
    _tareasFuture = _loadTareas();
  }

  Future<List<Tarea>> _loadTareas() {
    return Provider.of<ApiService>(context, listen: false).getTareas();
  }

  Future<void> _refreshTareas() async {
    setState(() {
      _tareasFuture = _loadTareas();
    });
  }

  String _getRemainingTime(DateTime fechaVencimiento) {
    final now = DateTime.now();
    final difference = fechaVencimiento.difference(now);

    if (difference.isNegative) {
      return 'Vencida';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} días restantes';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} horas restantes';
    } else {
      return '${difference.inMinutes} minutos restantes';
    }
  }

  Color _getStatusColor(DateTime fechaVencimiento, bool completada) {
    if (completada) return Colors.green;
    if (fechaVencimiento.isBefore(DateTime.now())) return Colors.red;
    if (fechaVencimiento.difference(DateTime.now()).inDays <= 3) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTareas,
        child: FutureBuilder<List<Tarea>>(
          future: _tareasFuture,
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
                    const Text('Error al cargar las tareas'),
       
             const SizedBox(height: 8),

                    ElevatedButton(
                      onPressed: _refreshTareas,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final tareas = snapshot.data ?? [];

            if (tareas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.assignment_turned_in, size: 48, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text('No tienes tareas pendientes'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refreshTareas,
                      child: const Text('Actualizar'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: tareas.length,
              itemBuilder: (context, index) {
                final tarea = tareas[index];
                final statusColor = _getStatusColor(tarea.fechaVencimiento, tarea.completada);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ExpansionTile(
                    leading: Icon(
                      tarea.completada ? Icons.check_circle : Icons.pending,
                      color: statusColor,
                    ),
                    title: Text(
                      tarea.titulo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: tarea.completada ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vence: ${DateFormat('dd/MM/yyyy HH:mm').format(tarea.fechaVencimiento)}',
                        ),
                        Text(
                          _getRemainingTime(tarea.fechaVencimiento),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Descripción:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(tarea.descripcion),
                            const SizedBox(height: 16),
                            if (!tarea.completada)
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Implement mark as complete logic
                                  },
                                  icon: const Icon(Icons.check),
                                  label: const Text('Marcar como completada'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}