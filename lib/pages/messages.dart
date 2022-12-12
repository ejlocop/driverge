import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
	const MessagesPage({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Center(
				child: TextButton(
					onPressed: () {
						Navigator.pushNamed(context, '/logs');
					},
					child: const Text('Messages'),
				),
			),
		);
	}
}
