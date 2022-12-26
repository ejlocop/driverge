import 'package:driverge/blocs/bloc/app_bloc.dart';
import 'package:driverge/common_widgets/contacts_list_builder.dart';
import 'package:driverge/models/contact.dart';
import 'package:driverge/models/message.dart';
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
	bool _isBlocking = false;

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
						Card(
							// padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
							// decoration: const BoxDecoration(color: Color.fromARGB(15, 0, 0, 0)),
							elevation: 2,
							margin: const EdgeInsets.all(20),
							child: Padding(
								padding: const EdgeInsets.all(20),
								child: _buildBlocker(context, state)
							)
						),
						const Text("Emergency Contacts",
							style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
						),
						const SizedBox(height: 20),
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
					disabled: _isBlocking,
					activeTextColor: Colors.white,
					inactiveTextColor: Colors.white54,
					activeIcon: const Icon(Icons.phone_disabled, color: Colors.white),
					inactiveText: 'Disabled',
					activeText: 'Enabled',
					activeToggleColor: const Color.fromRGBO(63, 81, 181, 1),
					inactiveToggleColor: Colors.indigo.shade100,
					onToggle: (isBlocked) async {

						// if (await Permission.phone.isDenied &&
								// await Permission.sms.isDenied) {
						if (await Permission.phone.isDenied) {
							await _checkPermissions();

							return;
						}

						setState(() {
						  _isBlocking = true;
						});

						context.read<AppBloc>().add(EnableBlockerEvent(isBlocked));
						
						await _toggleBlocker(isBlocked);
					},
				),
				Visibility(
					visible: state.isBlocked,
					child: Column(
						children: <Widget> [
							const SizedBox(height: 10),
							Text(
								"You won't be able to receive calls and messages but an automated message will be sent to the caller/sender when you receive a call or message.",
								style: TextStyle(
									// fontStyle: FontStyle.italic,
									fontSize: 14,
									fontWeight: FontWeight.w400,
									height: 1.4,
									color: Colors.grey.shade700
								),
							),
						],
					),
				)
			]
		);
	}

	// Widget _buildSwitchBlocker() => ;

	Future _toggleBlocker(bool isBlocked) async {
		try {
			final Map<String, dynamic> args = {
				"isBlocked": isBlocked
			};
			final methodChannel = await _methodChannel.invokeMethod('toggleBlocker', args);

			print('blocker $methodChannel');
			await LogService.logBlocking(isBlocked);

		} on PlatformException catch (e) {
			debugPrint("Failed to call method: '${e.message}'.");
		} finally {
			setState(() {
        _isBlocking = false;
      });
		}
	}

	Future _checkPermissions() async {
		try {
      final methodChannel = await _methodChannel.invokeMethod('requestPermissions');
      debugPrint(methodChannel);
    } on PlatformException catch (e) {
      debugPrint("Failed to call method: '${e.message}'.");
    }
	}

	// Future<Map<Permission, PermissionStatus>> _checkPermissions() async {
	// 	Map<Permission, PermissionStatus> statuses = await [
	// 		// Permission.phone,
	// 		Permission.sms,
	// 	].request();
	// 	return statuses;
	// }
}
