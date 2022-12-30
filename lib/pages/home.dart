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
	bool _isDefaultCallApp = false;
	bool _isDefaultSmsApp = false;

	Future<List<Contact>> _getContacts() async {
		return await _databaseService.contacts();
	}

	Future _fetchMessages() async {
		return await _databaseService.messages();
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
				return FutureBuilder(
					future: !state.messagesFetched ? _fetchMessages() : null,
					builder: (context, snapshot) {
						if (snapshot.connectionState == ConnectionState.waiting) {
							return const Center(
								child: CircularProgressIndicator(),
							);
						}

						if (snapshot.hasError) {
							return Center(
								child: Text('Error: ${snapshot.error}'),
							);
						}
						final _messages = snapshot.data ?? <Message>[];
						
            if(!state.messagesFetched) {
						  BlocProvider.of<AppBloc>(context).add(MessageSelected(_messages.first?.id));
              BlocProvider.of<AppBloc>(context).add(MessagesLoaded(_messages, _messages.isNotEmpty));
            }

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
					}
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
						if (await Permission.phone.isDenied && await Permission.sms.isDenied) {
							await _checkPermissions();
							return;
						}

						await _checkDefaultSmsApp();
						await _checkDefaultCallApp();
						if(isBlocked && (!_isDefaultCallApp || !_isDefaultSmsApp)) {
							await _setDefaultApp();
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

	Future _checkDefaultCallApp() async  {
		try {
			final bool isDefault = await _methodChannel.invokeMethod('checkDefaultCallApp');
			setState(() {
				_isDefaultCallApp = isDefault;
			});
		} on PlatformException catch (e) {
			debugPrint("Failed to call method: '${e.message}'.");
		}
	}

	Future _setDefaultCallApp() async {
		try {
			await _methodChannel.invokeMethod('selectDefaultCallApp');
		} on PlatformException catch (e) {
			debugPrint("Failed to call method: '${e.message}'.");
		}
	}

	Future _checkDefaultSmsApp() async  {
		try {
			final bool isDefault = await _methodChannel.invokeMethod('checkDefaultSmsApp');
			setState(() {
				_isDefaultSmsApp = isDefault;
			});
		} on PlatformException catch (e) {
			debugPrint("Failed to call method: '${e.message}'.");
		}
	}

	Future _setDefaultApp() async {
		ScaffoldMessenger.of(context).showSnackBar(SnackBar(
			content: Text("Please tap \"Open\" to set the Driverge app as the default SMS and Phone app.",
				style: TextStyle(
					fontSize: 14,
					color: Colors.grey.shade700
				),
			),
			action: SnackBarAction(
				label: 'Open',
				onPressed: () {
					openAppSettings();
				},
			),
			padding: EdgeInsets.all(20),
			backgroundColor: Colors.white,
			duration: Duration(seconds: 5),
			behavior: SnackBarBehavior.floating,
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(10),
			),
			margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
		));
	}

	// Future _checkPermissions() async {
	// 	try {
	//     final methodChannel = await _methodChannel.invokeMethod('requestPermissions');
	//   } on PlatformException catch (e) {
	//     debugPrint("Failed to call method: '${e.message}'.");
	//   }
	// }

	Future<Map<Permission, PermissionStatus>> _checkPermissions() async {
		Map<Permission, PermissionStatus> statuses = await [
			Permission.phone,
			Permission.sms,
		].request();
		return statuses;
	}
}
