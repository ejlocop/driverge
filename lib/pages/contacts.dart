import 'package:driverge/blocs/bloc/app_bloc.dart';
import 'package:driverge/common_widgets/contacts_list_builder.dart';
import 'package:driverge/models/contact.dart';
import 'package:driverge/services/database.dart';
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

	Future _addContactToDB(Contact contact) async {
		await _databaseService.inserContact(contact);
	}

  Future _deleteContact(Contact contact) async {
    await _databaseService.deleteContact(contact.id!);
  }

  Future _editContact(Contact contact) async {

	}

	@override
	Widget build(BuildContext context) {
		return Column(
			children: <Widget>[
				_buildForm(),
				const Divider(height: 20),
				Expanded(
					child: ContactsListBuilder(
						future: _getContacts(),
						showDelete: true,
						showEdit: true,
						onDelete: _deleteContact,
						onEdit: _editContact,
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
						padding: const EdgeInsets.all(16),
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
												ScaffoldMessenger.of(context).showSnackBar(
												const SnackBar(content: Text('Contact Added')));

												final Contact newContact = Contact(
													id: state.contacts.length + 1,
													name: _nameController.text,
													phone: _numberController.text
												);
												
												print('newContact: ${newContact.toMap()}');
												_addContactToDB(newContact);

												context.read<AppBloc>().add(AddNewContact(newContact));

												FocusScope.of(context).requestFocus(FocusNode());

												// _nameController.clear();
												// _numberController.clear();
											}
										},
										child: const Text('Add emergency contact'));
								},
							)
						]),
					),
				],
			),
		);
	}
}
