import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/materia_disponible.dart';
import '../models/preseleccion.dart';
import '../services/api_service.dart';

class PreseleccionScreen extends StatefulWidget {
  const PreseleccionScreen({Key? key}) : super(key: key);

  @override
  State<PreseleccionScreen> createState() => _PreseleccionScreenState();
}

class _PreseleccionScreenState extends State<PreseleccionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<MateriaDisponible>> _materiasDisponiblesFuture;
  late Future<List<Preseleccion>> _preseleccionesFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _materiasDisponiblesFuture = Provider.of<ApiService>(context, listen: false)
          .getMateriasDisponibles();
      _preseleccionesFuture =
          Provider.of<ApiService>(context, listen: false).getPreselecciones();
    });
  }

  Future<void> _preseleccionarMateria(MateriaDisponible materia) async {
    setState(() => _isLoading = true);
    try {
      final errorMessage = await Provider.of<ApiService>(context, listen: false)
          .preseleccionarMateria(materia.codigo);

      if (!mounted) return;

      if (errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Materia preseleccionada exitosamente')),
        );
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cancelarPreseleccion(String codigo) async {
    setState(() => _isLoading = true);
    try {
      final errorMessage = await Provider.of<ApiService>(context, listen: false)
          .cancelarPreseleccion(codigo);

      if (!mounted) return;

      if (errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preselección cancelada exitosamente')),
        );
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openMap(String coordinates) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$coordinates';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
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
        title: const Text('Preselección'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Materias Disponibles'),
            Tab(text: 'Preseleccionadas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMateriasDisponibles(),
          _buildPreseleccionadas(),
        ],
      ),
    );
  }

  Widget _buildMateriasDisponibles() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: FutureBuilder<List<MateriaDisponible>>(
        future: _materiasDisponiblesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final materias = snapshot.data ?? [];

          if (materias.isEmpty) {
            return const Center(
              child: Text('No hay materias disponibles'),
            );
          }

          return ListView.builder(
            itemCount: materias.length,
            itemBuilder: (context, index) {
              final materia = materias[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(materia.nombre),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Código: ${materia.codigo}'),
                      Text('Horario: ${materia.horario}'),
                      Text('Aula: ${materia.aula}'),
                    ],
                  ),
                  trailing: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _preseleccionarMateria(materia),
                        ),
                  onTap: () => _openMap(materia.ubicacion),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPreseleccionadas() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: FutureBuilder<List<Preseleccion>>(
        future: _preseleccionesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final preselecciones = snapshot.data ?? [];

          if (preselecciones.isEmpty) {
            return const Center(
              child: Text('No hay materias preseleccionadas'),
            );
          }

          return ListView.builder(
            itemCount: preselecciones.length,
            itemBuilder: (context, index) {
              final preseleccion = preselecciones[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(preseleccion.nombre),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Código: ${preseleccion.codigo}'),
                      Text('Aula: ${preseleccion.aula}'),
                      Text(
                        preseleccion.confirmada
                            ? 'Estado: Confirmada'
                            : 'Estado: Pendiente',
                        style: TextStyle(
                          color: preseleccion.confirmada
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: preseleccion.confirmada
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red),
                              onPressed: () =>
                                  _cancelarPreseleccion(preseleccion.codigo),
                            ),
                  onTap: () => _openMap(preseleccion.ubicacion),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
