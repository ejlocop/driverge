import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driverge/blocs/drawer/drawer_event.dart';
import 'package:driverge/blocs/drawer/nav_drawer_bloc.dart';
import 'package:driverge/blocs/drawer/nav_drawer_state.dart';

class NavDrawerWidget extends StatelessWidget {
	NavDrawerWidget({super.key});

	final List<_NavigationItem> _listItems = [
		_NavigationItem(NavItem.homePage, "Home", Icons.home),
		_NavigationItem(NavItem.contactsPage, "Contacts", Icons.contact_phone),
		_NavigationItem(NavItem.messagesPage, "Automatic Messages", Icons.message_rounded),
		_NavigationItem(NavItem.logsPage, "Logs", Icons.history),
	];

	@override
	Widget build(BuildContext context) => Drawer(
		child: Container(
      margin: EdgeInsets.only(top: 26 + MediaQuery.of(context).padding.top),
			child: ListView.builder(
				padding: EdgeInsets.zero,
				itemCount: _listItems.length,
				itemBuilder: (BuildContext context, int index) {
					return BlocBuilder<NavDrawerBloc, NavDrawerState>(
						builder: (BuildContext context, NavDrawerState state) => _buildItem(_listItems[index], state),
					);
				}
			),
		)
	);

	Widget _buildItem(_NavigationItem data, NavDrawerState state) => _makeListItem(data, state);

	Widget _makeListItem(_NavigationItem data, NavDrawerState state) => Card(
		shape: const ContinuousRectangleBorder(
			borderRadius: BorderRadius.zero
		),
		borderOnForeground: true,
		elevation: 0,
    surfaceTintColor: Colors.indigo.shade100,
		margin: EdgeInsets.zero,
		child: Builder(
			builder: (BuildContext context) => ListTile(
				title: Text(data.title,
					style: TextStyle(
						color: data.item == state.selectedItem
								? Colors.indigo
								: Colors.black,
					),
				),
				leading: Icon(data.icon,
					color: data.item == state.selectedItem
							? Colors.indigo
							: Colors.black,
				),
				onTap: () => _handleItemClick(context, data.item),
			),
		),
	);

	void _handleItemClick(BuildContext context, NavItem item) {
		BlocProvider.of<NavDrawerBloc>(context).add(NavigateTo(item));
		Navigator.pop(context);
	}
}

class _NavigationItem {
	late final NavItem item;
	late final String title;
	late final IconData icon;

	_NavigationItem(this.item, this.title, this.icon);
}
