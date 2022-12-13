import 'package:driverge/blocs/blocker/blocker_bloc.dart';
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
		return BlocProvider<BlockerBloc>(
			create: (context) => BlockerBloc(),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				children: <Widget>[
					Container(
						padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
						decoration: const BoxDecoration(color: Color.fromARGB(20, 0, 0, 0)),
						margin: const EdgeInsets.only(bottom: 60, top: 20, left: 20, right: 20),
						child: BlocBuilder<BlockerBloc, BlockerState>(
							builder: (context, state) {
								return Column(
									children: <Widget>[
										Container(
											margin: const EdgeInsets.only(bottom: 20),
											child: Column(
												children: [
													Text(
														"Blocking of calls and messages is ${state.isBlocked ? 'enabled' : 'disabled'}",
														style: const TextStyle(
															fontSize: 16,
															fontWeight: FontWeight.bold,
															color: Colors.black
														),
													),
													const SizedBox(height: 2),
													Text(
														"You won't be able to receive calls and messages but an automated message will be sent to the caller/sender when you receive a call or message.",
														style: TextStyle(
															fontStyle: FontStyle.italic,
															fontSize: 12,
															fontWeight: FontWeight.w400,
															height: 1.4,
															color: state.isBlocked ? Colors.transparent : Colors.grey
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
												context.read<BlockerBloc>().add(EnableBlockerEvent(isBlocked));

												if(await Permission.phone.isDenied &&
													await Permission.sms.isDenied
												) {
													await _checkPermissions();
												}
												
												// await _blockIncomingCalls(isBlocked);
											},
										)
									],
								);
							},
						),
					),
				],
			)
		);
	}

	// Widget _buildSwitchBlocker() => ;

	Future _blockIncomingCalls(bool isBlocked) async {
		try {
			final result = await _methodChannel.invokeMethod('setBlocking', {
				'isBlocked': isBlocked
			});
			print(result);
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
