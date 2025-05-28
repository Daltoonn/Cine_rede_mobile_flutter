import 'package:cine_rede/db/database_helper.dart';

Future<void> adicionarAmigo(String meuUid, String uidDoAmigo) async {
  final db = await DatabaseHelper.instance.database;

  final user = await db.query('users', where: 'id = ?', whereArgs: [meuUid]);
  if (user.isNotEmpty) {
    final currentFriends = user.first['friends']?.toString().split(',') ?? [];
    currentFriends.add(uidDoAmigo);
    await db.update('users', {'friends': currentFriends.join(',')},
        where: 'id = ?', whereArgs: [meuUid]);
  }
}

Future<void> removerAmigo(String meuUid, String uidDoAmigo) async {
  final db = await DatabaseHelper.instance.database;

  final user = await db.query('users', where: 'id = ?', whereArgs: [meuUid]);
  if (user.isNotEmpty) {
    final currentFriends = user.first['friends']?.toString().split(',') ?? [];
    currentFriends.remove(uidDoAmigo);
    await db.update('users', {'friends': currentFriends.join(',')},
        where: 'id = ?', whereArgs: [meuUid]);
  }
}
