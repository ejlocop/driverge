import 'package:flutter/material.dart';

class ContactsPage extends StatelessWidget {
	const ContactsPage({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Center(
				child: TextButton(
					onPressed: () {
						Navigator.pushNamed(context, '/logs');
					},
					child: const Text('Contacts'),
				),
			),
		);
	}
}
