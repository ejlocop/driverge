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
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_sms/flutter_sms.dart';

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
	final DatabaseService databaseService = DatabaseService();
	SpeechToText _speechToText = SpeechToText();
	String _lastWords = '';
	bool _speechEnabled = false;
	late Commands _commands;

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
	}

	Future _initSpeech() async {
		if(await Permission.microphone.isDenied) {
			return;
		}
		_speechEnabled = await _speechToText.initialize(
			onError: _errorListener,
			onStatus: _statusListener,
		);
		debugPrint("speecavailable $_speechEnabled");
		setState(() {});
	}

	/// Each time to start a speech recognition session
	Future _startListening() async {
		debugPrint("=================================================");
    await _stopListening();
    await Future.delayed(const Duration(milliseconds: 50));
    await _speechToText.listen(
        onResult: _onSpeechResult,
        cancelOnError: false,
        partialResults: true,
        listenMode: ListenMode.dictation,
        listenFor: const Duration(days: 1));
    setState(() {
      _speechEnabled = true;
    });
	}

	void _errorListener(SpeechRecognitionError error) {
		debugPrint(error.errorMsg.toString());
	}
	
	void _statusListener(String status) async {
		debugPrint("status $status");
		if (status == "done" && _speechEnabled) {
			setState(() {
				_speechEnabled = false;
			});
			await _startListening();
		}
	}

	Future _stopListening() async {
		setState(() {
      _speechEnabled = false;
    });
		await _speechToText.stop();
	}

	void _onSpeechResult(SpeechRecognitionResult result) {
		setState(() {
			_lastWords = result.recognizedWords;
		});

		print(_lastWords);
		_handleCommand();
	}

	void _handleCommand() {
		if(_lastWords.isEmpty) {
			return;
		}

    try {
      _commands.handle(_lastWords);
    } on UnknownCommandException catch (e) {
      debugPrint(e.toString());
    }
	}

	Future _onBarredContact(String source, String phoneNumber) async {
		Message message = _bloc.state.messages.firstWhere((message) => message.id == _bloc.state.selectedMessageId);

		try {
			final _result = await sendSMS(message: message.text, recipients: [phoneNumber], sendDirect: true);
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(
				content: Text("Sending message result: $_result"),
				duration: Duration(seconds: 2),
				behavior: SnackBarBehavior.floating,
				shape: StadiumBorder(),
				margin: EdgeInsets.all(20),
			));
			await LogService.logBarring(source, phoneNumber);
			await LogService.logFeedback(phoneNumber, message);
		} on Exception catch(e) {
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(
				content: Text("Failed sending a message ${e.toString()}"),
				duration: Duration(seconds: 2),
				behavior: SnackBarBehavior.floating,
				shape: StadiumBorder(),
				margin: EdgeInsets.all(20),
			));
		}
	}

	@override
	void dispose() {
		super.dispose();

		_speechToText.stop();
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
							child: !_speechToText.isListening ? Icon(Icons.mic_off) : Icon(Icons.mic),
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
