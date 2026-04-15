import 'package:mysql1/mysql1.dart';

class MysqlConnection {
  static String host = 'localhost';
  static String user = 'root';
  static String password = 'User01';
  static String db = 'DB_ReportYa';
  static int port = 3306;

  Future<MySqlConnection> getConnection() async {
    final settings = ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password,
      db: db,
    );
    return MySqlConnection.connect(settings);
  }
}
