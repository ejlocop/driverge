import 'package:driverge/blocs/bloc/app_bloc.dart';
import 'package:driverge/drawer_widget.dart';
import 'package:driverge/models/message.dart';
import 'package:driverge/models/nav.dart';
import 'package:driverge/pages/contacts.dart';
import 'package:driverge/pages/home.dart';
import 'package:driverge/pages/logs.dart';
import 'package:driverge/pages/messages.dart';
import 'package:driverge/services/database.dart';
import 'package:driverge/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:telephony/telephony.dart';

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

		_fetchMessages();
	}

	Future _fetchMessages() async {
		List<Message> messages = await databaseService.messages();
		
		_bloc.add(MessagesLoaded(messages, messages.isNotEmpty));
		_bloc.add(MessageSelected(messages.first.id ?? -1));
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
			child: Scaffold(
				drawer: NavDrawerWidget(),
				appBar: AppBar(
					title: BlocBuilder<AppBloc, AppState>(
						builder: (context, state) {
							return Text(_getAppbarTitle(state.selectedItem));
						},
					),
					centerTitle: true,
					backgroundColor: Colors.indigo,
				),
				body: AnimatedSwitcher(
					switchInCurve: Curves.easeInExpo,
					switchOutCurve: Curves.easeOutExpo,
					duration: const Duration(milliseconds: 500),
					child: _content,
				),
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
