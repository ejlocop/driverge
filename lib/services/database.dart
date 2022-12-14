import 'package:driverge/models/contact.dart';
import 'package:driverge/models/log.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
	// Singleton pattern
	static final DatabaseService _databaseService = DatabaseService._internal();
	factory DatabaseService() => _databaseService;
	DatabaseService._internal();

	static Database? _database;
	Future<Database> get database async {
		if (_database != null) return _database!;
		// Initialize the DB first time it is accessed
		_database = await _initDatabase();
		return _database!;
	}

	Future<Database> _initDatabase() async {
		final databasePath = await getDatabasesPath();

		// Set the path to the database. Note: Using the `join` function from the
		// `path` package is best practice to ensure the path is correctly
		// constructed for each platform.
		final dbpath = path.join(databasePath, 'driverge_db.db');

		// Set the version. This executes the onCreate function and provides a
		// path to perform database upgrades and downgrades.
		return await openDatabase(
			dbpath,
			onCreate: _onCreate,
			version: 1,
			onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
		);
	}

	// When the database is first created, create a table to store Contacts
	// and a table to store dogs.
	Future<void> _onCreate(Database db, int version) async {
		// Run the CREATE {contacts} TABLE statement on the database.
		await db.execute(
			'CREATE TABLE contacts(id INTEGER PRIMARY KEY, name TEXT, phone TEXT)',
		);
		// Run the CREATE {logs} TABLE statement on the database.
		await db.execute(
			'CREATE TABLE logs(id INTEGER PRIMARY KEY, type TEXT, message TEXT)',
		);
	}

	// Define a function that inserts Contacts into the database
	Future<void> inserContact(Contact contact) async {
		final db = await _databaseService.database;

		// Insert the Contact into the correct table. You might also specify the
		// `conflictAlgorithm` to use in case the same Contact is inserted twice.
		//
		// In this case, replace any previous data.
		await db.insert(
			'contacts',
			contact.toMap(),
			conflictAlgorithm: ConflictAlgorithm.replace,
		);
	}

	Future<void> insertLog(Log log) async {
		final db = await _databaseService.database;
		await db.insert(
			'logs',
			log.toMap(),
			conflictAlgorithm: ConflictAlgorithm.replace,
		);
	}

	// A method that retrieves all the Contacts from the Contacts table.
	Future<List<Contact>> contacts() async {
		// Get a reference to the database.
		final db = await _databaseService.database;

		// Query the table for all the Contacts.
		final List<Map<String, dynamic>> contacts = await db.query('contacts');

		// Convert the List<Map<String, dynamic> into a List<Contact>.
		return List.generate(contacts.length, (index) => Contact.fromMap(contacts[index]));
	}

	Future<Contact> contact(int id) async {
		final db = await _databaseService.database;
		final List<Map<String, dynamic>> maps = await db.query('contacts', where: 'id = ?', whereArgs: [id]);
		return Contact.fromMap(maps[0]);
	}

	Future<List<Log>> logs() async {
		final db = await _databaseService.database;
		final List<Map<String, dynamic>> logs = await db.query('logs');
		return List.generate(logs.length, (index) => Log.fromMap(logs[index]));
	}

	// A method that updates a Contact data from the Contacts table.
	Future<void> updateContact(Contact contact) async {
		// Get a reference to the database.
		final db = await _databaseService.database;

		// Update the given Contact
		await db.update(
			'contacts',
			contact.toMap(),
			// Ensure that the Contact has a matching id.
			where: 'id = ?',
			// Pass the Contact's id as a whereArg to prevent SQL injection.
			whereArgs: [contact.id],
		);
	}

	// A method that deletes a Contact data from the Contacts table.
	Future<void> deleteContact(int id) async {
		// Get a reference to the database.
		final db = await _databaseService.database;

		// Remove the {Contact} from the database.
		await db.delete(
			'contacts',
			// Use a `where` clause to delete a specific Contact.
			where: 'id = ?',
			// Pass the Contact's id as a whereArg to prevent SQL injection.
			whereArgs: [id],
		);
	}

  Future<void> deleteContacts() async {
    final db = await _databaseService.database;

    await db.delete('contacts');
  }

  Future<void> deleteLogs() async {
    final db = await _databaseService.database;

    await db.delete('logs');
  }

  Future<void> cleanDatabase() async {
    deleteContacts();
    deleteLogs();
  }
}
