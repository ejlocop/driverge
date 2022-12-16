import 'package:driverge/blocs/bloc/app_bloc.dart';
import 'package:driverge/common_widgets/contacts_list_builder.dart';
import 'package:driverge/models/contact.dart';
import 'package:driverge/models/log.dart';
import 'package:driverge/services/database.dart';
import 'package:driverge/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsPage extends StatefulWidget {
	const ContactsPage({super.key});

	@override
	ContactsPageState createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage> {
	final _nameController = TextEditingController();
	final _numberController = TextEditingController();
	final _formKey = GlobalKey<FormState>();
	final DatabaseService _databaseService = DatabaseService();

	@override
	void initState() {
		super.initState();
	}

	@override
	void dispose() {
		_nameController.dispose();
		_numberController.dispose();
		super.dispose();
	}

	Future<List<Contact>> _getContacts() async {
		return await _databaseService.contacts();
	}

	Future _addContact(Contact contact) async {
		await _databaseService.inserContact(contact);
		setState(() {});
	}

	Future _deleteContact(Contact contact) async {
		await _databaseService.deleteContact(contact.id!);
		setState(() {});
	}

	@override
	Widget build(BuildContext context) {
		final bool wasContactsFetched = BlocProvider.of<AppBloc>(context).state.contactsFetched;
		return Column(
			children: <Widget>[
				_buildForm(),
				const Divider(height: 20),
				Expanded(
					child: ContactsListBuilder(
						future: wasContactsFetched ? null : _getContacts(),
						showDelete: true,
						showCall: true,
						onDelete: _deleteContact
					)
				)
			],
		);
	}

	Widget _buildForm() {
		return Form(
			key: _formKey,
			child: Column(
				children: <Widget>[
					Container(
						padding: const EdgeInsets.all(20),
						child: Column(children: [
							TextFormField(
								// enabled: _contacts.length >= 5,
								controller: _nameController,
								decoration: const InputDecoration(hintText: 'Name'),
								keyboardType: TextInputType.name,
								validator: (value) {
									return (value == null || value.isEmpty)
											? 'Please enter a name'
											: null;
								},
							),
							TextFormField(
								// enabled: _contacts.length >= 5,
								controller: _numberController,
								decoration: const InputDecoration(hintText: 'Phone Number'),
								keyboardType: TextInputType.phone,
								validator: (value) {
									return (value == null || value.isEmpty)
										? 'Please enter a number'
										: null;
								},
							),
							const SizedBox(height: 20),
							BlocBuilder<AppBloc, AppState>(
								builder: (context, state) {
									return ElevatedButton(
										onPressed: () {
											if (_formKey.currentState!.validate()) {
												final Contact newContact = Contact(
														id: state.contacts.length + 1,
														name: _nameController.text,
														phone: _numberController.text
												);

												_onContactAdded(newContact, context);
											}
										},
										child: const Text('Add emergency contact')
									);
								},
							)
						]),
					),
				],
			),
		);
	}

	void _onContactAdded(Contact contact, BuildContext context) async {
		ScaffoldMessenger.of(context)
			.showSnackBar(const SnackBar(content: Text('Contact Added')));

		_addContact(contact);

		BlocProvider.of<AppBloc>(context).add(AddNewContact(contact));

		FocusScope.of(context).requestFocus(FocusNode());

    await LogService.logContact(contact, LogContactType.add);

		_nameController.clear();
		_numberController.clear();
	}
}
