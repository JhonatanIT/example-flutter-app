import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:example_app/database/database_service.dart';
import 'package:example_app/model/todo.dart';

class TodoDB {
  final tableName = 'todos';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
        "id" INTEGER NOT NULL,
        "title" TEXT NOT NULL,
        "created_at" INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int)),
        "updated_at" INTEGER,
        PRIMARY KEY ("id" AUTOINCREMENT)
    );""");
  }

  Future<void> insertInitialDataFromCSV() async {
    //Load initial data from csv
    final _rawData = await rootBundle.loadString("assets/mycsv.csv");
    List<List<dynamic>> _listData =
        const CsvToListConverter().convert(_rawData);

    final database = await DatabaseService().database;
    final todos = await database.rawQuery("""SELECT * FROM $tableName""");

    //The first time the database is created
    if (todos.isEmpty) {
      for (var todo in _listData) {
        //No headers
        if (todo[1] != "title") {
          await database.rawInsert(
              """INSERT INTO $tableName (title, created_at) VALUES (?,?)""",
              [todo[1], DateTime.now().millisecondsSinceEpoch]);
        }
      }
    }
  }

  Future<int> create({required String title}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
        """INSERT INTO $tableName (title, created_at) VALUES (?,?)""",
        [title, DateTime.now().millisecondsSinceEpoch]);
  }

  Future<List<Todo>> fetchAll() async {
    final database = await DatabaseService().database;
    final todos = await database.rawQuery(
        """SELECT * FROM $tableName  ORDER BY COALESCE(updated_at, created_at)""");
    return todos.map((todo) => Todo.fromSqfliteDatabase(todo)).toList();
  }

  // A method that retrieves all the todos from the todo table.
  Future<List<Todo>> todos() async {
    // Get a reference to the database.
    final database = await DatabaseService().database;

    // Query the table for all Todos.
    final List<Map<String, dynamic>> maps = await database.query('$tableName');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        title: maps[i]['title'],
        createdAt: maps[i]['created_at'],
        updatedAt: maps[i]['updated_at'],
      );
    });
  }

  Future<Todo> fetchById(int id) async {
    final database = await DatabaseService().database;
    final todo = await database
        .rawQuery("""SELECT * FROM $tableName WHERE ID = ?""", [id]);
    return Todo.fromSqfliteDatabase(todo.first);
  }

  Future<int> update({required int id, String? title}) async {
    final database = await DatabaseService().database;

    return await database.update(
      tableName,
      {
        if (title != null) 'title': title,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    //await database.rawDelete("""DELETE FROM $tableName WHERE id = ?""", [id]);
    await database.delete(tableName, where: "id = ?", whereArgs: [id]);
  }
}
