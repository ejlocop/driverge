import 'package:driverge/blocs/bloc/app_bloc.dart';
import 'package:driverge/common_widgets/contacts_list_builder.dart';
import 'package:driverge/models/contact.dart';
import 'package:driverge/models/log.dart';
import 'package:driverge/services/database.dart';
import 'package:driverge/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
	const HomePage({super.key});

	@override
	HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
	// bool _isBlocked = false;
	static const MethodChannel _methodChannel = MethodChannel('com.ejlocop.driverge/channel');
	final DatabaseService _databaseService = DatabaseService();

	Future<List<Contact>> _getContacts() async {
		return await _databaseService.contacts();
	}

	@override
	void initState() {
		super.initState();
	}

	@override
	void dispose() {
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return BlocBuilder<AppBloc, AppState>(
			builder: (context, state) {
				return Column(
					mainAxisSize: MainAxisSize.min,
					children: <Widget>[
						Container(
							padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
							decoration: const BoxDecoration(color: Color.fromARGB(15, 0, 0, 0)),
							margin: const EdgeInsets.all(20),
							child: _buildBlocker(context, state)
						),
						const Text("Emergency Contacts",
							style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
						),
						Expanded(
							child: ContactsListBuilder(
								future: state.contactsFetched ? null : _getContacts(),
								showCall: true,
							)
						)
					],
				);
			},
		);
	}

	Widget _buildBlocker (BuildContext context, AppState state) {
		return Column(
			children: <Widget>[
				Container(
					margin: const EdgeInsets.only(bottom: 10),
					child: Column(
						children: [
							Text(
								"Blocking of all incoming calls and messages are ${state.isBlocked ? 'enabled' : 'disabled'}",
								style: const TextStyle(
									fontSize: 16,
									fontWeight: FontWeight.bold,
									color: Colors.black
								),
							),
							const SizedBox(height: 5),
							Text(
								"You won't be able to receive calls and messages but an automated message will be sent to the caller/sender when you receive a call or message.",
								style: TextStyle(
									fontStyle: FontStyle.italic,
									fontSize: 12,
									fontWeight: FontWeight.w400,
									height: 1.4,
									color: state.isBlocked ? Colors.grey : Colors.transparent
								),
							)
						],
					),
				),
				FlutterSwitch(
					width: 150.0,
					height: 60.0,
					valueFontSize: 18.0,
					toggleSize: 45.0,
					value: state.isBlocked,
					borderRadius: 30.0,
					activeColor: Colors.indigoAccent,
					padding: 8.0,
					showOnOff: true,
					activeTextColor: Colors.white,
					inactiveTextColor: Colors.white54,
					activeIcon: const Icon(Icons.phone_disabled, color: Colors.white),
					inactiveText: 'Disabled',
					activeText: 'Enabled',
					activeToggleColor: const Color.fromRGBO(63, 81, 181, 1),
					inactiveToggleColor: Colors.indigo.shade100,
					onToggle: (isBlocked) async {
						context.read<AppBloc>().add(EnableBlockerEvent(isBlocked));

						if (await Permission.phone.isDenied &&
								await Permission.sms.isDenied) {
							await _checkPermissions();
						}

						await _blockIncomingCalls(isBlocked);
					},
				)
			]
		);
	}

	// Widget _buildSwitchBlocker() => ;

	Future _blockIncomingCalls(bool isBlocked) async {
		try {
			// final result = await _methodChannel.invokeMethod('setBlocking', {
			// 	'isBlocked': isBlocked
			// });
			// print(result);
			await LogService.logBlocking(isBlocked);

		} on PlatformException catch (e) {
			print("Failed to get battery level: '${e.message}'.");
		}
	}

	Future<Map<Permission, PermissionStatus>> _checkPermissions() async {
		Map<Permission, PermissionStatus> statuses = await [
			Permission.phone,
			Permission.sms,
		].request();
		return statuses;
	}
}
