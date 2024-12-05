import 'dart:io';
import 'package:draft1/models/deuda.dart';
import 'package:draft1/models/evento.dart';
import 'package:draft1/models/horario.dart';
import 'package:draft1/models/tarea.dart';
import 'package:draft1/models/video.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/noticia.dart';

class DatabaseHelper {
  static const _databaseName = "UasdApp.db";
  static const _databaseVersion = 2;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // Initialize SQLite
  static Future<void> initializeDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI for Windows and Linux
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    // Ensure the directory exists
    await Directory(dirname(path)).create(recursive: true);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createHorarioTable(db);
    }
  }

  Future<void> _createHorarioTable(Database db) async {
    await db.execute('''
      CREATE TABLE horario (
        id INTEGER PRIMARY KEY,
        usuario_id INTEGER NOT NULL,
        materia TEXT NOT NULL,
        aula TEXT NOT NULL,
        fecha_hora INTEGER NOT NULL,
        ubicacion TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE noticias (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      img TEXT NOT NULL,
      url TEXT NOT NULL,
      date TEXT NOT NULL,
      parsed_date INTEGER NOT NULL,
      timestamp INTEGER NOT NULL
    )
  ''');
    await db.execute('''
    CREATE TABLE eventos (
      id INTEGER PRIMARY KEY,
      titulo TEXT NOT NULL,
      descripcion TEXT NOT NULL,
      fecha_evento INTEGER NOT NULL,
      lugar TEXT NOT NULL,
      coordenadas TEXT NOT NULL,
      timestamp INTEGER NOT NULL
    )
  ''');
    await db.execute('''
  CREATE TABLE videos (
    id INTEGER PRIMARY KEY,
    titulo TEXT NOT NULL,
    url TEXT NOT NULL,
    fecha_publicacion INTEGER NOT NULL,
    timestamp INTEGER NOT NULL
  )
''');

    await db.execute('''
  CREATE TABLE deudas (
    id INTEGER PRIMARY KEY,
    usuario_id INTEGER NOT NULL,
    monto REAL NOT NULL,
    pagada INTEGER NOT NULL,
    fecha_actualizacion INTEGER NOT NULL,
    timestamp INTEGER NOT NULL
  )
''');

    await db.execute('''
  CREATE TABLE tareas (
    id INTEGER PRIMARY KEY,
    usuario_id INTEGER NOT NULL,
    titulo TEXT NOT NULL,
    descripcion TEXT NOT NULL,
    fecha_vencimiento INTEGER NOT NULL,
    completada INTEGER NOT NULL,
    timestamp INTEGER NOT NULL
  )
''');

    await _createHorarioTable(db);
  }

  Future<int> insertNoticia(Noticia noticia) async {
    final db = await database;
    return await db.insert(
      'noticias',
      {
        'id': noticia.id,
        'title': noticia.title,
        'img': noticia.img,
        'url': noticia.url,
        'date': noticia.date,
        'parsed_date': noticia.parsedDate.millisecondsSinceEpoch,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertNoticias(List<Noticia> noticias) async {
    final db = await database;
    await db.transaction((txn) async {
      // Clear existing noticias
      await txn.delete('noticias');

      // Insert new noticias
      for (var noticia in noticias) {
        await txn.insert(
          'noticias',
          {
            'id': noticia.id,
            'title': noticia.title,
            'img': noticia.img,
            'url': noticia.url,
            'date': noticia.date,
            'parsed_date': noticia.parsedDate.millisecondsSinceEpoch,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Noticia>> getNoticias() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'noticias',
      orderBy: 'parsed_date DESC',
    );

    return List.generate(maps.length, (i) {
      return Noticia(
        id: maps[i]['id'] as String,
        title: maps[i]['title'] as String,
        img: maps[i]['img'] as String,
        url: maps[i]['url'] as String,
        date: maps[i]['date'] as String,
        parsedDate:
            DateTime.fromMillisecondsSinceEpoch(maps[i]['parsed_date'] as int),
      );
    });
  }

  Future<bool> shouldRefreshCache() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT timestamp FROM noticias ORDER BY timestamp DESC LIMIT 1
    ''');

    if (result.isEmpty) return true;

    final lastUpdate =
        DateTime.fromMillisecondsSinceEpoch(result.first['timestamp'] as int);
    final now = DateTime.now();

    // Refresh if more than 15 minutes have passed
    return now.difference(lastUpdate).inMinutes > 15;
  }

  Future<void> insertEventos(List<Evento> eventos) async {
    final db = await database;
    await db.transaction((txn) async {
      // Clear existing eventos
      await txn.delete('eventos');

      // Insert new eventos
      for (var evento in eventos) {
        await txn.insert(
          'eventos',
          {
            'id': evento.id,
            'titulo': evento.titulo,
            'descripcion': evento.descripcion,
            'fecha_evento': evento.fechaEvento.millisecondsSinceEpoch,
            'lugar': evento.lugar,
            'coordenadas': evento.coordenadas,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Evento>> getEventos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'eventos',
      orderBy: 'fecha_evento ASC',
    );

    return List.generate(maps.length, (i) {
      return Evento(
        id: maps[i]['id'] as int,
        titulo: maps[i]['titulo'] as String,
        descripcion: maps[i]['descripcion'] as String,
        fechaEvento:
            DateTime.fromMillisecondsSinceEpoch(maps[i]['fecha_evento'] as int),
        lugar: maps[i]['lugar'] as String,
        coordenadas: maps[i]['coordenadas'] as String,
      );
    });
  }

  Future<bool> shouldRefreshEventos() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT timestamp FROM eventos ORDER BY timestamp DESC LIMIT 1
  ''');

    if (result.isEmpty) return true;

    final lastUpdate =
        DateTime.fromMillisecondsSinceEpoch(result.first['timestamp'] as int);
    final now = DateTime.now();

    // Refresh if more than 15 minutes have passed
    return now.difference(lastUpdate).inMinutes > 15;
  }

  Future<void> insertVideos(List<Video> videos) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('videos');

      for (var video in videos) {
        await txn.insert(
          'videos',
          {
            'id': video.id,
            'titulo': video.titulo,
            'url': video.url,
            'fecha_publicacion': video.fechaPublicacion.millisecondsSinceEpoch,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Video>> getVideos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'videos',
      orderBy: 'fecha_publicacion DESC',
    );

    return List.generate(maps.length, (i) {
      return Video(
        id: maps[i]['id'] as int,
        titulo: maps[i]['titulo'] as String,
        url: maps[i]['url'] as String,
        fechaPublicacion: DateTime.fromMillisecondsSinceEpoch(
            maps[i]['fecha_publicacion'] as int),
      );
    });
  }

  Future<bool> shouldRefreshVideos() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT timestamp FROM videos ORDER BY timestamp DESC LIMIT 1
  ''');

    if (result.isEmpty) return true;

    final lastUpdate =
        DateTime.fromMillisecondsSinceEpoch(result.first['timestamp'] as int);
    return DateTime.now().difference(lastUpdate).inMinutes > 15;
  }

  Future<void> insertDeudas(List<Deuda> deudas) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('deudas');

      for (var deuda in deudas) {
        await txn.insert(
          'deudas',
          {
            'id': deuda.id,
            'usuario_id': deuda.usuarioId,
            'monto': deuda.monto,
            'pagada': deuda.pagada ? 1 : 0,
            'fecha_actualizacion':
                deuda.fechaActualizacion.millisecondsSinceEpoch,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Deuda>> getDeudas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'deudas',
      orderBy: 'fecha_actualizacion DESC',
    );

    return List.generate(maps.length, (i) {
      return Deuda(
        id: maps[i]['id'] as int,
        usuarioId: maps[i]['usuario_id'] as int,
        monto: maps[i]['monto'] as double,
        pagada: (maps[i]['pagada'] as int) == 1,
        fechaActualizacion: DateTime.fromMillisecondsSinceEpoch(
          maps[i]['fecha_actualizacion'] as int,
        ),
      );
    });
  }

  Future<bool> shouldRefreshDeudas() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT timestamp FROM deudas ORDER BY timestamp DESC LIMIT 1
  ''');

    if (result.isEmpty) return true;

    final lastUpdate =
        DateTime.fromMillisecondsSinceEpoch(result.first['timestamp'] as int);
    return DateTime.now().difference(lastUpdate).inMinutes > 15;
  }

  Future<void> insertTareas(List<Tarea> tareas) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('tareas');

      for (var tarea in tareas) {
        await txn.insert(
          'tareas',
          {
            'id': tarea.id,
            'usuario_id': tarea.usuarioId,
            'titulo': tarea.titulo,
            'descripcion': tarea.descripcion,
            'fecha_vencimiento': tarea.fechaVencimiento.millisecondsSinceEpoch,
            'completada': tarea.completada ? 1 : 0,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Tarea>> getTareas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tareas',
      orderBy: 'fecha_vencimiento ASC',
    );

    return List.generate(maps.length, (i) {
      return Tarea(
        id: maps[i]['id'] as int,
        usuarioId: maps[i]['usuario_id'] as int,
        titulo: maps[i]['titulo'] as String,
        descripcion: maps[i]['descripcion'] as String,
        fechaVencimiento: DateTime.fromMillisecondsSinceEpoch(
          maps[i]['fecha_vencimiento'] as int,
        ),
        completada: (maps[i]['completada'] as int) == 1,
      );
    });
  }

  Future<bool> shouldRefreshTareas() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT timestamp FROM tareas ORDER BY timestamp DESC LIMIT 1
  ''');

    if (result.isEmpty) return true;

    final lastUpdate =
        DateTime.fromMillisecondsSinceEpoch(result.first['timestamp'] as int);
    return DateTime.now().difference(lastUpdate).inMinutes > 15;
  }

  Future<void> insertHorarios(List<Horario> horarios) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('horario');

      for (var horario in horarios) {
        await txn.insert(
          'horario',
          {
            'id': horario.id,
            'usuario_id': horario.usuarioId,
            'materia': horario.materia,
            'aula': horario.aula,
            'fecha_hora': horario.fechaHora.millisecondsSinceEpoch,
            'ubicacion': horario.ubicacion,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Horario>> getHorarios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'horario',
      orderBy: 'fecha_hora ASC',
    );

    return List.generate(maps.length, (i) {
      return Horario(
        id: maps[i]['id'] as int,
        usuarioId: maps[i]['usuario_id'] as int,
        materia: maps[i]['materia'] as String,
        aula: maps[i]['aula'] as String,
        fechaHora:
            DateTime.fromMillisecondsSinceEpoch(maps[i]['fecha_hora'] as int),
        ubicacion: maps[i]['ubicacion'] as String,
      );
    });
  }

  Future<bool> shouldRefreshHorario() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT timestamp FROM horario ORDER BY timestamp DESC LIMIT 1
    ''');

    if (result.isEmpty) return true;

    final lastUpdate =
        DateTime.fromMillisecondsSinceEpoch(result.first['timestamp'] as int);
    return DateTime.now().difference(lastUpdate).inMinutes > 15;
  }
}
