import 'dart:convert';

class Message {
	final int? id;
	final String text;

	Message({
		this.id,
		required this.text
	});

	// Convert a Contact into a Map. The keys must correspond to the names of the
	// columns in the database.
	Map<String, dynamic> toMap() {
		return {
			'id': id,
			'text': text,
		};
	}

	factory Message.fromMap(Map<String, dynamic> map) {
		return Message(
			id: map['id']?.toInt() ?? 0,
			text: map['text'] ?? '',
		);
	}

	String toJson() => json.encode(toMap());

	factory Message.fromJson(String source) =>
			Message.fromMap(json.decode(source));

	// Implement toString to make it easier to see information about
	// each Contact when using the print statement.
	@override
	String toString() {
		return 'Message(id: $id, text: $text)';
	}
}

enum LogMessageType {
	add,
	delete,
	select
}
