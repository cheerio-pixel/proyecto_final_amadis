import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/evento.dart';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({Key? key}) : super(key: key);

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  late Future<List<Evento>> _eventosFuture;

  @override
  void initState() {
    super.initState();
    _eventosFuture = _loadEventos();
  }

  Future<List<Evento>> _loadEventos() {
    return Provider.of<ApiService>(context, listen: false).getEventos();
  }

  Future<void> _refreshEventos() async {
    setState(() {
      _eventosFuture = _loadEventos();
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
        title: const Text('Eventos UASD'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshEventos,
        child: FutureBuilder<List<Evento>>(
          future: _eventosFuture,
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
                    const Text('Error al cargar los eventos'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refreshEventos,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final eventos = snapshot.data ?? [];

            if (eventos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_busy, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No hay eventos programados'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refreshEventos,
                      child: const Text('Actualizar'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: eventos.length,
              itemBuilder: (context, index) {
                final evento = eventos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          evento.titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(evento.fechaEvento),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(evento.descripcion),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _openMap(evento.coordenadas),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  evento.lugar,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
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