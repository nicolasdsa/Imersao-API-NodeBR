import 'package:app_asd_diagnostic/db/database.dart';

class AnswerOptionsDao {
  static const String tableSql = 'CREATE TABLE $_tableName('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'option_text TEXT, '
      'id_question INTEGER, '
      'FOREIGN KEY (id_question) REFERENCES questions(id))';

  static const String _tableName = 'answer_options';

  final dbHelper = DatabaseHelper.instance;

  Future<List<String>> getOptionsForQuestion(int questionId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      _tableName,
      columns: ['option_text'],
      where: 'id_question = ?',
      whereArgs: [questionId],
    );
    return result.map((row) => row['option_text'] as String).toList();
  }
}
