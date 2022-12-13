import 'package:driverge/bloc/drawer/nav_drawer_bloc.dart';
import 'package:driverge/bloc/drawer/nav_drawer_state.dart';
import 'package:driverge/drawer_widget.dart';
import 'package:driverge/pages/contacts.dart';
import 'package:driverge/pages/home.dart';
import 'package:driverge/pages/logs.dart';
import 'package:driverge/pages/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Driverge',
			debugShowCheckedModeBanner: false,
			theme: ThemeData(
				primarySwatch: Colors.indigo, 
				scaffoldBackgroundColor: Colors.white
			),
			home: MyHomePage(),
		);
	}
}

class MyHomePage extends StatefulWidget {
	@override
	MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
	late NavDrawerBloc _bloc;
	late Widget _content;

	@override
	void initState() {
		super.initState();
		_bloc = NavDrawerBloc();
		_content = _getContentForState(_bloc.state.selectedItem);
	}

	@override
	void dispose() {
		super.dispose();
	}

	@override
	Widget build(BuildContext context) => BlocProvider<NavDrawerBloc>(
		create: (BuildContext context) => _bloc,
		child: BlocListener<NavDrawerBloc, NavDrawerState>(
			listener: (BuildContext context, NavDrawerState state) {
				setState(() {
					_content = _getContentForState(state.selectedItem);
				});
			},
			child: BlocBuilder<NavDrawerBloc, NavDrawerState>(
				builder: (BuildContext context, NavDrawerState state) => Scaffold(
					drawer: NavDrawerWidget(),
					appBar: AppBar(
						title: Text(_getAppbarTitle(state.selectedItem)),
						centerTitle: false,
						backgroundColor: Colors.indigo,
					),
					body: AnimatedSwitcher(
						switchInCurve: Curves.easeInExpo,
						switchOutCurve: Curves.easeOutExpo,
						duration: const Duration(seconds: 1),
						child: _content,
					),
				),
			),
		)
	);

	_getAppbarTitle(NavItem state) {
		switch (state) {
			case NavItem.homePage:
				return 'Home';
			case NavItem.contactsPage:
				return 'Contacts';
			case NavItem.messagesPage:
				return 'Automatic Messages';
			case NavItem.logsPage:
				return 'Logs';
			default:
				return '';
		}
	}

	_getContentForState(NavItem state) {
		switch (state) {
			case NavItem.homePage:
				return const HomePage();
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
