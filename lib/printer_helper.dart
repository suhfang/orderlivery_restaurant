
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

final String tablePrinter = 'printer';
final String columnName = 'name';
final String columnIp = 'ip';
final String columnSqliteId = 'id';
final String columnIsDefault = 'is_default';

class Printer {

  int id;
  String name;
  String ip;
  int isDefault;

  Printer({
    this.id,
    this.name,
    this.ip,
    this.isDefault
  });

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'name': this.name,
      'ip': this.ip,
      'is_default': isDefault,
    };
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map[columnName] = name;
    map[columnIp] = ip;
    map[columnIsDefault] = isDefault;
    return map;
  }

  Printer.fromMap(Map<String, dynamic> map) {
    id = map[columnSqliteId];
    ip = map[columnIp];
    name = map[columnName];
    isDefault = map[columnIsDefault];
  }
}

class PrinterProvider {

  Database db;
  static PrinterProvider shared = PrinterProvider();

  Future open(String path) async {
    db = await openDatabase(path, version: 1, 
        onCreate: (Database db, int version) async {
          await db.execute(
            '''
              create table $tablePrinter (
                $columnSqliteId INTEGER primary key autoincrement,
                $columnName TEXT,
                $columnIp TEXT NOT NULL,
                $columnIsDefault INTEGER NOT NULL DEFAULT 0
              );
            '''
          );
        });
  }

  Future<Printer> addPrinter(Printer printer) async {
    printer.id = await db.insert(
      tablePrinter, 
      printer.toMap()
    );
    
    return printer;
  }

  Future<int> updatePrinter(Printer printer) async {
    int updated = await db.update(tablePrinter, printer.toMap(),
         where: '$columnSqliteId = ?', 
      whereArgs: [printer.id]);
    return updated;
    
  }

  Future<int> deletePrinter(int id) async {
    return await db.delete(
      tablePrinter, 
      where: '$columnSqliteId = ?', 
      whereArgs: [id]
    );
  }

  Future<Printer> getDefaultPrinter() async {
    var maps =  await db.query(
      tablePrinter, 
      where: '$columnIsDefault = ?', 
      whereArgs: [1]
    );
    return maps.length > 0 ? Printer.fromMap(maps.first) : null;
  }

  Future<Printer> setAsDefaultPrinter(Printer printer) async {
    var printers = await getAllPrinters();
    for (var i = 0; i < printers.length; i++) {
      if (printers[i].id != printer.id) {
        printers[i].isDefault = 0;
        await updatePrinter(printers[i]);
      } else {
        printer.isDefault = 1;
        await updatePrinter(printer);
      }
    }
  }

  Future<List<Printer>> getAllPrinters() async {
    List<Map> maps = await db.query(
        tablePrinter 
    );
    return maps.map((e) => Printer.fromMap(e)).toList();
  }
  
}

