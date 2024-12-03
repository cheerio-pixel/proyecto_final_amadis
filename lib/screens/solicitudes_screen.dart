import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/solicitud.dart';
import '../models/tipo_solicitud.dart';
import '../services/api_service.dart';

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({Key? key}) : super(key: key);

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  late Future<List<Solicitud>> _solicitudesFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _solicitudesFuture = _loadSolicitudes();
  }

  Future<List<Solicitud>> _loadSolicitudes() {
    return Provider.of<ApiService>(context, listen: false).getMisSolicitudes();
  }

  Future<void> _refreshSolicitudes() async {
    setState(() {
      _solicitudesFuture = _loadSolicitudes();
    });
  }


  Future<void> _mostrarFormularioSolicitud() async {
    if (!mounted) return;
    
    final apiService = Provider.of<ApiService>(context, listen: false);
    final tiposSolicitudes = await apiService.getTiposSolicitudes();
    
    if (!mounted) return;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FormularioSolicitud(
        tiposSolicitudes: tiposSolicitudes,
        onSubmit: (tipo, descripcion) async {
          final success = await apiService.crearSolicitud(tipo, descripcion);
          if (context.mounted) {
            Navigator.pop(context, success);
          }
        },
      ),
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud creada exitosamente')),
      );
      _refreshSolicitudes();
    } else if (result == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear la solicitud'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelarSolicitud(Solicitud solicitud) async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    
    try {
      final success = await Provider.of<ApiService>(context, listen: false)
          .cancelarSolicitud(solicitud.id);
      
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud cancelada exitosamente')),
        );
        _refreshSolicitudes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cancelar la solicitud'),
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

  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'aprobada':
        return Colors.green;
      case 'rechazada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Solicitudes'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshSolicitudes,
        child: FutureBuilder<List<Solicitud>>(
          future: _solicitudesFuture,
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
                    const Text('Error al cargar las solicitudes'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refreshSolicitudes,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final solicitudes = snapshot.data ?? [];

            if (solicitudes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inbox, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No tienes solicitudes'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: solicitudes.length,
              itemBuilder: (context, index) {
                final solicitud = solicitudes[index];
                final statusColor = _getStatusColor(solicitud.estado);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ExpansionTile(
                    title: Text(solicitud.tipo),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado: ${solicitud.estado}',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(solicitud.fechaSolicitud)}',
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
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(solicitud.descripcion),
                            if (solicitud.respuesta != null) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Respuesta:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(solicitud.respuesta!),
                              Text(
                                'Fecha respuesta: ${DateFormat('dd/MM/yyyy HH:mm').format(solicitud.fechaRespuesta!)}',
                              ),
                            ],
                            if (solicitud.estado.toLowerCase() == 'pendiente' &&
                                !_isLoading)
                              Center(
                                child: TextButton.icon(
                                  onPressed: () => _cancelarSolicitud(solicitud),
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  label: const Text(
                                    'Cancelar Solicitud',
                                    style: TextStyle(color: Colors.red),
                                  ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _mostrarFormularioSolicitud,
        label: const Text('Nueva Solicitud'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _FormularioSolicitud extends StatefulWidget {
  final List<TipoSolicitud> tiposSolicitudes;
  final Future<void> Function(String tipo, String descripcion) onSubmit;

  const _FormularioSolicitud({
    required this.tiposSolicitudes,
    required this.onSubmit,
  });

  @override
  State<_FormularioSolicitud> createState() => _FormularioSolicitudState();
}

class _FormularioSolicitudState extends State<_FormularioSolicitud> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTipo;
  final _descripcionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nueva Solicitud',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de Solicitud',
                border: OutlineInputBorder(),
              ),
              items: widget.tiposSolicitudes
                  .map((tipo) => DropdownMenuItem(
                        value: tipo.codigo,
                        child: Text(tipo.descripcion),
                      ))
                  .toList(),
              onChanged: _isSubmitting ? null : (value) => setState(() => _selectedTipo = value),
              validator: (value) =>
                  value == null ? 'Seleccione un tipo de solicitud' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              enabled: !_isSubmitting,
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Ingrese una descripción' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        setState(() => _isSubmitting = true);
                        try {
                          await widget.onSubmit(
                              _selectedTipo!, _descripcionController.text);
                        } finally {
                          if (mounted) {
                            setState(() => _isSubmitting = false);
                          }
                        }
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enviar Solicitud'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }
}