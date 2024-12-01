import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:draft1/database/database_helper.dart';
import 'package:draft1/models/deuda.dart';
import 'package:draft1/models/evento.dart';
import 'package:draft1/models/materia_disponible.dart';
import 'package:draft1/models/noticia.dart';
import 'package:draft1/models/preseleccion.dart';
import 'package:draft1/models/tarea.dart';
import 'package:draft1/models/user.dart';
import 'package:draft1/models/video.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String baseUrl = 'https://uasdapi.ia3x.com';

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post('$baseUrl/login',
          data: {'username': username, 'password': password});
      if (response.statusCode == 200 && response.data["success"]) {
        final token = response.data["data"]["authToken"];
        if (token != null) {
          await _storage.write(key: 'token', value: token);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> resetPassword(PasswordResetData data) async {
    await _dio.post('$baseUrl/reset_password', data: data.toJson());
  }

  Future<User?> getUserInfo() async {
    try {
      final response = await _dio.get('$baseUrl/info_usuario');
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Noticia>> getNoticias() async {
    try {
      final db = DatabaseHelper.instance;
      final shouldRefresh = await db.shouldRefreshCache();

      if (!shouldRefresh) {
        // Retornar datos del caché si están frescos
        return await db.getNoticias();
      }

      // Si necesitamos actualizar, hacemos la llamada a la API
      final response = await _dio.get('$baseUrl/noticias');
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> noticiasJson = response.data['data'];
        final noticias =
            noticiasJson.map((json) => Noticia.fromJson(json)).toList();

        // Guardar en caché
        await db.insertNoticias(noticias);
        return noticias;
      }

      // Si la API falla, intentar retornar datos del caché
      return await db.getNoticias();
    } catch (e) {
      print('Error getting noticias: $e');
      // En caso de error, intentar retornar datos del caché
      try {
        return await DatabaseHelper.instance.getNoticias();
      } catch (dbError) {
        print('Error getting cached noticias: $dbError');
        return [];
      }
    }
  }

// In api_service.dart
  Future<List<Evento>> getEventos() async {
    try {
      final db = DatabaseHelper.instance;
      final shouldRefresh = await db.shouldRefreshEventos();

      if (!shouldRefresh) {
        return await db.getEventos();
      }

      final response = await _dio.get('$baseUrl/eventos');
      if (response.statusCode == 200) {
        final List<dynamic> eventosJson = response.data;
        final eventos = eventosJson
            .where((json) => json != null)
            .map((json) => Evento.fromJson(json))
            .toList();

        // Save to cache if we have valid entries
        if (eventos.isNotEmpty) {
          await db.insertEventos(eventos);
        }

        return eventos;
      }

      // If API call fails, return cached data
      return await db.getEventos();
    } catch (e) {
      print('Error getting eventos: $e');
      // On error, try to return cached data
      try {
        return await DatabaseHelper.instance.getEventos();
      } catch (dbError) {
        print('Error getting cached eventos: $dbError');
        return [];
      }
    }
  }

  Future<List<Video>> getVideos() async {
    try {
      final db = DatabaseHelper.instance;
      final shouldRefresh = await db.shouldRefreshVideos();

      if (!shouldRefresh) {
        return await db.getVideos();
      }

      final response = await _dio.get('$baseUrl/videos');
      if (response.statusCode == 200) {
        final List<dynamic> videosJson = response.data;
        final videos = videosJson.map((json) => Video.fromJson(json)).toList();

        if (videos.isNotEmpty) {
          await db.insertVideos(videos);
        }

        return videos;
      }

      return await db.getVideos();
    } catch (e) {
      print('Error getting videos: $e');
      return await DatabaseHelper.instance.getVideos();
    }
  }

  Future<List<Deuda>> getDeudas() async {
    try {
      final db = DatabaseHelper.instance;
      final shouldRefresh = await db.shouldRefreshDeudas();

      if (!shouldRefresh) {
        return await db.getDeudas();
      }

      final response = await _dio.get('$baseUrl/deudas');
      if (response.statusCode == 200) {
        final List<dynamic> deudasJson = response.data;
        final deudas = deudasJson.map((json) => Deuda.fromJson(json)).toList();

        if (deudas.isNotEmpty) {
          await db.insertDeudas(deudas);
        }

        return deudas;
      }

      return await db.getDeudas();
    } catch (e) {
      print('Error getting deudas: $e');
      return await DatabaseHelper.instance.getDeudas();
    }
  }

  Future<List<Tarea>> getTareas() async {
    try {
      final db = DatabaseHelper.instance;
      final shouldRefresh = await db.shouldRefreshTareas();

      if (!shouldRefresh) {
        return await db.getTareas();
      }

      final response = await _dio.get('$baseUrl/tareas');
      if (response.statusCode == 200) {
        final List<dynamic> tareasJson = response.data;
        final tareas = tareasJson.map((json) => Tarea.fromJson(json)).toList();

        if (tareas.isNotEmpty) {
          await db.insertTareas(tareas);
        }

        return tareas;
      }

      return await db.getTareas();
    } catch (e) {
      print('Error getting tareas: $e');
      return await DatabaseHelper.instance.getTareas();
    }
  }

  Future<List<MateriaDisponible>> getMateriasDisponibles() async {
    try {
      final response = await _dio.get('$baseUrl/materias_disponibles');
      if (response.statusCode == 200) {
        final List<dynamic> materiasJson = response.data;
        return materiasJson
            .map((json) => MateriaDisponible.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting materias disponibles: $e');
      return [];
    }
  }

  Future<String?> preseleccionarMateria(String codigo) async {
    try {
      final response = await _dio.post(
        '$baseUrl/preseleccionar_materia',
        data: jsonEncode(codigo),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
      return !response.data['success'] ? response.data['error'] : null;
    } catch (e) {
      print('Error preseleccionando materia: $e');
      if (e is DioException) {
        print('Response data: ${e.response}');
        print('Response headers: ${e.response?.headers}');
      }
      return "Error preseleccionando materia.";
    }
  }

  Future<String?> cancelarPreseleccion(String codigo) async {
    try {
      final response = await _dio.post(
        '$baseUrl/cancelar_preseleccion_materia',
        data: jsonEncode(codigo),
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
      return !response.data['success'] ? response.data['error'] : null;
    } catch (e) {
      print('Error cancelando preselección: $e');
      return "Error cancelando preselección.";
    }
  }

  Future<List<Preseleccion>> getPreselecciones() async {
    try {
      final response = await _dio.get('$baseUrl/ver_preseleccion');
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> preseleccionesJson = response.data['data'];
        return preseleccionesJson
            .map((json) => Preseleccion.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting preselecciones: $e');
      return [];
    }
  }
}
