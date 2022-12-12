

import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class HomePage extends StatefulWidget {
	const HomePage({super.key});
  
	@override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
	bool status = false;
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				mainAxisSize: MainAxisSize.min,
				children: <Widget> [
					Container(
						padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
						decoration: const BoxDecoration(color: Color.fromARGB(20, 0, 0, 0)),
						margin: const EdgeInsets.only(
							bottom: 60,
							top: 20,
							left: 20,
							right: 20
						),
						child: FlutterSwitch(
							width: 125.0,
							height: 55.0,
							valueFontSize: 25.0,
							toggleSize: 45.0,
							value: status,
							borderRadius: 30.0,
							activeColor: Colors.indigo,
							padding: 8.0,
							showOnOff: false,
							onToggle: (val) {
								setState(() {
									status = val;
								});
							},
						),
					),
				],
			)
		);
	}
}
