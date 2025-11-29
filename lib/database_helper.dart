import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  // Informações do Banco de Dados
  static const _databaseName = "tarefas_202310148.db"; // SEU RA AQUI
  static const _databaseVersion = 1;

  static const table = 'tarefas_table';

  // Nomes das colunas da tabela
  static const columnId = 'id';
  static const columnTitulo = 'titulo';
  static const columnDescricao = 'descricao';
  static const columnPrioridade = 'prioridade';
  static const columnCriadoEm = 'criadoEm';
  // SEU CAMPO PERSONALIZADO:
  static const columnAmbienteExecucao = 'ambienteExecucao';

  // Padrão Singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnTitulo TEXT NOT NULL,
            $columnDescricao TEXT NOT NULL,
            $columnPrioridade TEXT NOT NULL,
            $columnCriadoEm TEXT NOT NULL,
            $columnAmbienteExecucao TEXT NOT NULL
          )
          ''');
  }

  // --- MÉTODOS CRUD ---
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    print("JSON DO OBJETO CRIADO: $row");
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
