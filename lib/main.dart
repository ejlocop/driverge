import 'package:driverge/blocs/bloc/app_bloc.dart';
import 'package:driverge/drawer_widget.dart';
import 'package:driverge/models/nav.dart';
import 'package:driverge/pages/contacts.dart';
import 'package:driverge/pages/home.dart';
import 'package:driverge/pages/logs.dart';
import 'package:driverge/pages/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(const MyApp());

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

	@override
	void initState() {
		super.initState();
		_bloc = AppBloc();
		_content = _getContentForState(_bloc.state.selectedItem);
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
