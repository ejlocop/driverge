import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsPage extends StatefulWidget {
	const ContactsPage({super.key});

	@override
	ContactsPageState createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage> {
	final _nameController = TextEditingController();
	final _numberController = TextEditingController();
	late final SharedPreferences prefs;

	@override
	void initState() async {
		super.initState();
		prefs = await SharedPreferences.getInstance();
	}

	@override
	void dispose() {
		_nameController.dispose();
		_numberController.dispose();
		
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(

		);
	}

	Future<List<Contact>> _fetchContacts(SharedPreferences prefs) async {
		final String? contactsString = await prefs.getString('contacts');
		final List<Contact> contacts = Contact.decode(contactsString ?? '');
		return contacts;
	}
}

class Contact {
	final int id;
	final String name;
	final String number;

	Contact({required this.id, required this.name, required this.number});

	factory Contact.fromJson(Map<String, dynamic> jsonData) {
		return Contact(
			id: jsonData['id'],
			name: jsonData['name'],
			number: jsonData['phone']
		);
	}

	static Map<String, dynamic> toMap(Contact contact) => {
		'id': contact.id,
		'name': contact.name,
		'number': contact.number
	};

	static String encode(List<Contact> contacts) => json.encode(
		contacts
				.map<Map<String, dynamic>>((contact) => Contact.toMap(contact))
				.toList()
	);

	static List<Contact> decode(String contacts) => (json.decode(contacts) as List<dynamic>)
		.map<Contact>((item) => Contact.fromJson(item))
		.toList();
}