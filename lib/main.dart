import 'dart:convert';

import 'package:driverge/blocs/bloc/app_bloc.dart';
import 'package:driverge/drawer_widget.dart';
import 'package:driverge/models/message.dart';
import 'package:driverge/models/nav.dart';
import 'package:driverge/pages/contacts.dart';
import 'package:driverge/pages/home.dart';
import 'package:driverge/pages/logs.dart';
import 'package:driverge/pages/messages.dart';
import 'package:driverge/services/commands.dart';
import 'package:driverge/services/database.dart';
import 'package:driverge/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:telephony/telephony.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

void main() {
	WidgetsFlutterBinding.ensureInitialized();
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Driverge',
			debugShowCheckedModeBanner: false,
			theme: ThemeData(
				primarySwatch: Colors.indigo,
				scaffoldBackgroundColor: Colors.white,
			),
			home: const MyHomePage(),
		);
	}
}

class MyHomePage extends StatefulWidget {
	const MyHomePage({super.key});

	@override
	MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
	late AppBloc _bloc;
	late Widget _content;
	final methodChannel = MethodChannel('com.ejlocop.driverge/channel');
	final telephony = Telephony.instance;
	final DatabaseService databaseService = DatabaseService();
	SpeechToText _speechToText = SpeechToText();
	String _lastWords = '';
	bool _speechEnabled = false;
	late Commands _commands;
	int _counter = 0;

	@override
	void initState() {
		super.initState();
		_bloc = AppBloc();
		_content = _getContentForState(_bloc.state.selectedItem);
		methodChannel.setMethodCallHandler((call) async {
			if(call.method == 'barredContact') {
				final args = call.arguments;
				// debugPrint("args $args");
				final phoneNumber = args['phoneNumber'] as String;
				final source = args['source'] as String;
				_onBarredContact(source, phoneNumber);
			}
		});
		_commands = Commands(bloc: _bloc);
		_initSpeech();

		// fetchCounter();
	}

	Future _initSpeech() async {
		if(await Permission.microphone.isDenied) {
			return;
		}
		_speechEnabled = await _speechToText.initialize();
		setState(() {});
	}

	// Future fetchCounter() async {
	// 	final response = await http.get(Uri.parse('https://api.countapi.xyz/hit/ejlocop.com/4b7579fd-6cb0-47b6-9391-bea71c555d1f'));
	// 	if(response.statusCode == 200) {
	// 		setState(() {
	// 			_counter = json.decode(response.body)['value'] as int;
	// 		});
	// 	}
	// }

	/// Each time to start a speech recognition session
	void _startListening() async {
		await _speechToText.listen(
			onResult: _onSpeechResult,
			listenFor: const Duration(minutes: 1),
		);
		setState(() {});
	}

	void _stopListening() async {
		String? message;
		await _speechToText.stop();
		try {
			_commands.handle(_lastWords);
			message = _lastWords;
		} on UnknownCommandException catch(e) {
			debugPrint(e.toString());
			message = e.message as String;
		}
		
		ScaffoldMessenger.of(context)
			.showSnackBar(SnackBar(
				content: Text(message),
				duration: Duration(seconds: 2),
				behavior: SnackBarBehavior.floating,
				shape: StadiumBorder(),
				margin: EdgeInsets.all(20),
			));
		setState(() {});
	}

	void _onSpeechResult(SpeechRecognitionResult result) {
		setState(() {
			if(result.finalResult) {
				_stopListening();
			}
			_lastWords = result.recognizedWords;
		});
	}

	Future _onBarredContact(String source, String phoneNumber) async {
		Message message = _bloc.state.messages.firstWhere((message) => message.id == _bloc.state.selectedMessageId);

		await telephony.sendSms(to: phoneNumber, message: message.text);
		await LogService.logBarring(source, phoneNumber);
		await LogService.logFeedback(phoneNumber, message);
	}

	@override
	void dispose() {
		super.dispose();
	}

	@override
	Widget build(BuildContext context) => BlocProvider<AppBloc>(
		create: (BuildContext context) => _bloc,
		child: BlocListener<AppBloc, AppState>(
			listener: (BuildContext context, AppState state) {
				setState(() {
					_content = _getContentForState(state.selectedItem);
				});
			},
			child: BlocBuilder<AppBloc, AppState>(
				builder: (context, state) {

					return Scaffold(
						drawer: NavDrawerWidget(),
						appBar: AppBar(
							title: Text(_getAppbarTitle(state.selectedItem)),
							centerTitle: true,
							backgroundColor: Colors.indigo,
						),
						body: AnimatedSwitcher(
							switchInCurve: Curves.easeInExpo,
							switchOutCurve: Curves.easeOutExpo,
							duration: const Duration(milliseconds: 500),
							child: _content,
						),
						floatingActionButton: state.selectedItem != NavItem.homePage ? null : FloatingActionButton(
							onPressed: () async {
								if(await Permission.microphone.isDenied) {
									await Permission.microphone.request();
									return;
								}
								
								if(!_speechEnabled) {
									await _initSpeech();
								}

								_speechToText.isNotListening ? _startListening() : _stopListening();
							},
							child: _speechToText.isListening ? Icon(Icons.mic_off) : Icon(Icons.mic),
							backgroundColor: Colors.indigo,
							tooltip: "Please hold the Mic button to speak and initiate the voice command.",
						)
					);
				},		
			)
		)
	);

	_getAppbarTitle(NavItem state) {
		switch (state) {
			case NavItem.contactsPage:
				return 'Contacts';
			case NavItem.messagesPage:
				return 'Automatic Messages';
			case NavItem.logsPage:
				return 'Logs';
			default:
				return 'Home';
		}
	}

	_getContentForState(NavItem state) {
		switch (state) {
			case NavItem.contactsPage:
				return const ContactsPage();
			case NavItem.messagesPage:
				return const MessagesPage();
			case NavItem.logsPage:
				return const LogsPage();
			default:
				return const HomePage();
		}
	}
}
