import 'package:flutter/material.dart';

class LogsPage extends StatelessWidget {
	const LogsPage({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Center(
				child: TextButton(
					onPressed: () {
						Navigator.pushNamed(context, '/logs');
					},
					child: const Text('Logs'),
				),
			),
		);
	}
}
