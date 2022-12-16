import 'package:driverge/models/contact.dart';
import 'package:driverge/models/log.dart';
import 'package:driverge/models/message.dart';
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

		final dbpath = path.join(databasePath, 'driverge_db.db');

		return await openDatabase(
			dbpath,
			onCreate: _onCreate,
			version: 1,
			onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
		);
	}

	Future<void> _onCreate(Database db, int version) async {
		// Run the CREATE {contacts} TABLE statement on the database.
		await db.execute(
			'CREATE TABLE contacts(id INTEGER PRIMARY KEY, name TEXT, phone TEXT)',
		);
		// Run the CREATE {logs} TABLE statement on the database.
		await db.execute(
			'CREATE TABLE logs(id INTEGER PRIMARY KEY, type TEXT, message TEXT, date TEXT DEFAULT (datetime(\'now\', \'localtime\')))',
		);

		// Run the CREATE {logs} TABLE statement on the database.
		await db.execute(
			'CREATE TABLE messages(id INTEGER PRIMARY KEY, text TEXT)',
		);

		_seedMessages();
	}

	void _seedMessages() async {
		List<Message> messages = [
			Message(id: 1, text: 'I will respond to your message when I come back'),
			Message(id: 2, text: 'I\'m currently driving'),
			Message(id: 3, text: 'I\'m driving, safety first!'),
			Message(id: 4, text: 'Text me later, I am in charge of the wheels today'),
		];
		
		for (Message message in messages) {
			await inserMessage(message);
		}
	}

	Future<void> inserContact(Contact contact) async {
		final db = await _databaseService.database;
		await db.insert(
			'contacts',
			contact.toMap(),
			conflictAlgorithm: ConflictAlgorithm.replace,
		);
	}

	Future<void> inserMessage(Message message) async {
		final db = await _databaseService.database;
		await db.insert(
			'messages',
			message.toMap(),
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

	Future<List<Contact>> contacts() async {
		// Get a reference to the database.
		final db = await _databaseService.database;

		// Query the table for all the Contacts.
		final List<Map<String, dynamic>> contacts = await db.query('contacts');

		// Convert the List<Map<String, dynamic> into a List<Contact>.
		return List.generate(contacts.length, (index) => Contact.fromMap(contacts[index]));
	}

	Future<List<Message>> messages() async {
		
		final db = await _databaseService.database;
		
		final List<Map<String, dynamic>> messages = await db.query('messages');
		
		return List.generate(messages.length, (index) => Message.fromMap(messages[index]));
	}

	Future<List<Log>> logs() async {
		final db = await _databaseService.database;
		final List<Map<String, dynamic>> logs = await db.query('logs');
		return List.generate(logs.length, (index) => Log.fromMap(logs[index])).reversed.toList();
	}

	// A method that deletes a Contact data from the Contacts table.
	Future<void> deleteContact(int id) async {
		final db = await _databaseService.database;

		await db.delete(
			'contacts',
			where: 'id = ?',
			whereArgs: [id],
		);
	}

	// A method that deletes a Contact data from the Contacts table.
	Future<void> deleteMessage(int id) async {
		final db = await _databaseService.database;

		// Remove the {Contact} from the database.
		await db.delete(
			'messages',
			where: 'id = ?',
			whereArgs: [id],
		);
	}

	Future<void> deleteContacts() async {
		final db = await _databaseService.database;

		await db.delete('contacts');
	}
	
	Future<void> deleteMessages() async {
		final db = await _databaseService.database;

		await db.delete('messages');
	}

	Future<void> deleteLogs() async {
		final db = await _databaseService.database;

		await db.delete('logs');
	}

	Future<void> cleanDatabase() async {
		deleteContacts();
		deleteLogs();
		deleteMessages();
	}
}
