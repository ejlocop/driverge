import 'dart:convert';

class Contact {
	final int? id;
	final String name;
	final String phone;

	Contact({
		this.id,
		required this.name,
		required this.phone,
	});

	// Convert a Contact into a Map. The keys must correspond to the names of the
	// columns in the database.
	Map<String, dynamic> toMap() {
		return {
			'id': id,
			'name': name,
			'phone': phone,
		};
	}

	factory Contact.fromMap(Map<String, dynamic> map) {
		return Contact(
			id: map['id']?.toInt() ?? 0,
			name: map['name'] ?? '',
			phone: map['phone'] ?? '',
		);
	}

	String toJson() => json.encode(toMap());

	factory Contact.fromJson(String source) => Contact.fromMap(json.decode(source));

	// Implement toString to make it easier to see information about
	// each Contact when using the print statement.
	@override
	String toString() {
		return 'Contact(id: $id, name: $name, phone: $phone)';
	}
}
