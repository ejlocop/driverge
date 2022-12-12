import 'package:driverge/pages/contacts.dart';
import 'package:driverge/pages/home.dart';
import 'package:driverge/pages/logs.dart';
import 'package:driverge/pages/messages.dart';
import 'package:flutter/material.dart';

class NavigationDrawer extends StatelessWidget {
	const NavigationDrawer({super.key});

	@override
	Widget build(BuildContext context) => Drawer(
		child: SingleChildScrollView(
			child: Column(
				children: <Widget>[
					buildMenuItems(context),
				],
			)
		),
	);

	Widget buildMenuItems(BuildContext context) => Container(
		padding: const EdgeInsets.all(16),
		margin: EdgeInsets.only(top: 26 + MediaQuery.of(context).padding.top),
		child: Wrap(
			runSpacing: 16, 
			children: [
				ListTile(
					leading: const Icon(Icons.home_filled),
					title: const Text('Home'),
					onTap: () {
						Navigator.of(context).pushReplacement(
							MaterialPageRoute(builder: (context) => const HomePage()));
					}
				),
				ListTile(
					leading: const Icon(Icons.contact_phone),
					title: const Text('Contacts'),
					onTap: () {
						Navigator.of(context).push(
							MaterialPageRoute(builder: (context) => const ContactsPage()));
					}
				),
				ListTile(
					leading: const Icon(Icons.sms),
					title: const Text('Automatic Messages'),
					onTap: () {
						Navigator.of(context).push(
							MaterialPageRoute(builder: (context) => const MessagesPage()));
					}
				),
				Divider(color: Colors.indigo.shade900),
				ListTile(
					leading: const Icon(Icons.history_outlined),
					title: const Text('Logs'),
					onTap: () {
						Navigator.of(context).push(
							MaterialPageRoute(builder: (context) => const LogsPage()));
					}
				),
			]
		)
	);
}
