import 'package:draft1/models/horario.dart';
import 'package:draft1/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HorarioScreen extends StatefulWidget {
  const HorarioScreen({Key? key}) : super(key: key);

  @override
  State<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen> {
  late Future<List<Horario>> _horarioFuture;

  @override
  void initState() {
    super.initState();
    _horarioFuture = _loadHorario();
  }

  Future<List<Horario>> _loadHorario() {
    return Provider.of<ApiService>(context, listen: false).getHorario();
  }

  Future<void> _refreshHorario() async {
    setState(() {
      _horarioFuture = _loadHorario();
    });
  }

  Future<void> _openMap(String coordinates) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$coordinates';
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el mapa')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Horario'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshHorario,
        child: FutureBuilder<List<Horario>>(
          future: _horarioFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Error al cargar el horario'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refreshHorario,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final horarios = snapshot.data ?? [];

            if (horarios.isEmpty) {
              return const Center(
                child: Text('No hay clases programadas'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: horarios.length,
              itemBuilder: (context, index) {
                final horario = horarios[index];
                final isPast = horario.fechaHora.isBefore(DateTime.now());

                return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: ListTile(
                      
                        leading: Icon(
                          Icons.class_,
                          color: isPast ? Colors.grey : Colors.blue,
                        ),
                        title: Text(
                          horario.materia,
                          style: TextStyle(
                            decoration:
                                isPast ? TextDecoration.lineThrough : null,
                            color: isPast ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aula: ${horario.aula}',
                              style: TextStyle(
                                color: isPast ? Colors.grey : null,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE dd/MM/yyyy HH:mm', 'es')
                                  .format(horario.fechaHora),
                              style: TextStyle(
                                color: isPast ? Colors.grey : null,
                              ),
                            ),
                          ],
                        ),
                      trailing: IconButton(
                        icon: const Icon(Icons.location_on),
                        onPressed: () => _openMap(horario.ubicacion),
                        color: isPast ? Colors.grey : Colors.red,
                      ),
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
