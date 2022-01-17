import 'package:f_contact_ex/domain/contact.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ContactHelper {
  //singleton
  //construtor interno
  static final ContactHelper _instance = ContactHelper.internal();

  //criação do factory para retornar a instância
  factory ContactHelper() => _instance;

  //contacthelp.instance
  ContactHelper.internal();

  Database? _db;

  Future<Database?> get db async {
    if (_db == null) _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    String? databasesPath = await getDatabasesPath();
    if (databasesPath == null) databasesPath = "";
    String path = join(databasesPath, "contacts.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE ${Contact.contactTable}(${Contact.idColumn} INTEGER PRIMARY KEY, "
          "                                 ${Contact.nameColumn} TEXT, "
          "                                 ${Contact.emailColumn} TEXT, "
          "                                 ${Contact.phoneColumn} TEXT, "
          "                                 ${Contact.imgColumn} TEXT) ");
    });
  }

  Future<Contact> saveContact(Contact c) async {
    Database? dbContact = await db;
    if (dbContact != null)
      c.id = await dbContact.insert(Contact.contactTable, c.toMap());
    return c;
  }

  Future<Contact?> getContact(int id) async {
    Database? dbContact = await db;
    if (dbContact != null) {
      List<Map> maps = await dbContact.query(Contact.contactTable,
          columns: [
            Contact.idColumn,
            Contact.nameColumn,
            Contact.emailColumn,
            Contact.phoneColumn,
            Contact.imgColumn
          ],
          where: "${Contact.idColumn} = ?",
          whereArgs: [id]);
      if (maps.length > 0)
        return Contact.fromMap(maps.first);
      else
        return null;
    }
    return null;
  }

  Future<int> deleteContact(int id) async {
    Database? dbContact = await db;
    if (dbContact != null) {
      return await dbContact.delete(Contact.contactTable,
          where: "${Contact.idColumn} = ?", whereArgs: [id]);
    } else
      return 0;
  }

  Future<int> updateContact(Contact c) async {
    Database? dbContact = await db;
    if (dbContact != null) {
      return await dbContact.update(Contact.contactTable, c.toMap(),
          where: "${Contact.idColumn} = ?", whereArgs: [c.id]);
    } else {
      return 0;
    }
  }

  Future<List> getAllContact() async {
    Database? dbContact = await db;
    if (dbContact != null) {
      List listMap = await dbContact.query(Contact.contactTable);
      List<Contact> listContacts = [];

      for (Map m in listMap) {
        listContacts.add(Contact.fromMap(m));
      }
      return listContacts;
    } else {
      return [];
    }
  }

  Future<List<Contact>> searchContacts(String keyword) async {
    Database? dbContact = await db;
    if (dbContact != null) {
      List listMap = await dbContact.query(Contact.contactTable,
          columns: [
            Contact.idColumn,
            Contact.nameColumn,
            Contact.emailColumn,
            Contact.phoneColumn,
            Contact.imgColumn
          ],
          where: "${Contact.nameColumn} LIKE ?",
          whereArgs: ['%$keyword%']);
      List<Contact> listContacts = [];

      if (listMap.length > 0)
        for (Map m in listMap) {
          print(m);
          listContacts.add(Contact.fromMap(m));
        }
      return listContacts;
    } else {
      return [];
    }
  }

  Future<int?> getNumber() async {
    Database? dbContact = await db;
    if (dbContact != null) {
      return Sqflite.firstIntValue(await dbContact
          .rawQuery("select count(*) from ${Contact.contactTable}"));
    } else {
      return 0;
    }
  }
}
