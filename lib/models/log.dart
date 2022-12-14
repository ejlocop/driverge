import 'dart:convert';

class Log {
	final int? id;
	final String type;
	final String message;

	Log({
		this.id,
		required this.type,
		required this.message,
	});

	// Convert a Contact into a Map. The keys must correspond to the names of the
	// columns in the database.
	Map<String, dynamic> toMap() {
		return {
			'id': id,
			'type': type,
			'message': message,
		};
	}

	factory Log.fromMap(Map<String, dynamic> map) {
		return Log(
			id: map['id']?.toInt() ?? 0,
			type: map['type'] ?? '',
			message: map['message'] ?? '',
		);
	}

	String toJson() => json.encode(toMap());

	factory Log.fromJson(String source) => Log.fromMap(json.decode(source));

	// Implement toString to make it easier to see information about
	// each Contact when using the print statement.
	@override
	String toString() {
		return 'Contact(id: $id, name: $type, age: $message)';
	}
}
