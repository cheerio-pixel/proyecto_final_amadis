import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Image.asset(
                  'assets/images/uasd-logo.png',
                  height: 120,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Universidad Autónoma de Santo Domingo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Misión',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Formar críticamente los científicos, profesionales, técnicos y profesionales del arte necesarios para coadyuvar al desarrollo sostenible de la sociedad dominicana.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Iniciar Sesión'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Add link to registration page
                    launchUrl(Uri.parse('https://uasd.edu.do/registro'));
                  },
                  child: const Text('Estudia con Nosotros'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}