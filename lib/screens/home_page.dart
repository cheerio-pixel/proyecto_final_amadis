import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UASD App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF003DA6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'UASD App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('Noticias'),
              onTap: () => Navigator.pushNamed(context, '/noticias'),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Horarios'),
              onTap: () => Navigator.pushNamed(context, '/horarios'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_calendar),
              title: const Text('Preselección'),
              onTap: () => Navigator.pushNamed(context, '/preseleccion'),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Deuda'),
              onTap: () => Navigator.pushNamed(context, '/deuda'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Solicitudes'),
              onTap: () => Navigator.pushNamed(context, '/solicitudes'),
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Mis Tareas'),
              onTap: () => Navigator.pushNamed(context, '/tareas'),
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Eventos'),
              onTap: () => Navigator.pushNamed(context, '/eventos'),
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Videos'),
              onTap: () => Navigator.pushNamed(context, '/videos'),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Acerca de'),
              onTap: () => Navigator.pushNamed(context, '/acerca'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Salir'),
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _buildMenuCard(
            context,
            'Noticias',
            Icons.newspaper,
            '/noticias',
          ),
          _buildMenuCard(
            context,
            'Horarios',
            Icons.schedule,
            '/horarios',
          ),
          _buildMenuCard(
            context,
            'Preselección',
            Icons.edit_calendar,
            '/preseleccion',
          ),
          _buildMenuCard(
            context,
            'Deuda',
            Icons.account_balance_wallet,
            '/deuda',
          ),
          _buildMenuCard(
            context,
            'Solicitudes',
            Icons.description,
            '/solicitudes',
          ),
          _buildMenuCard(
            context,
            'Mis Tareas',
            Icons.assignment,
            '/tareas',
          ),
          _buildMenuCard(
            context,
            'Eventos',
            Icons.event,
            '/eventos',
          ),
          _buildMenuCard(
            context,
            'Videos',
            Icons.video_library,
            '/videos',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}