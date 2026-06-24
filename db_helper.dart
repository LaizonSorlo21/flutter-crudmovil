import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class SQLHelper {
  // Crear la tabla en la base de datos
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )""");
  }

  // Abrir o crear la base de datos
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      path.join(await sql.getDatabasesPath(), 'celular_crud.db'),
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Insertar un nuevo registro (Create)
  static Future<int> createItem(String title, String? descrption) async {
    final db = await SQLHelper.db();
    final data = {'title': title, 'description': descrption};
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Leer todos los registros (Read)
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id DESC");
  }

  // Actualizar un registro (Update)
  static Future<int> updateItem(
      int id, String title, String? descrption) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': descrption,
      'createdAt': DateTime.now().toString()
    };
    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Borrar un registro (Delete)
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      print("Error al eliminar el elemento: $err");
    }
  }
}