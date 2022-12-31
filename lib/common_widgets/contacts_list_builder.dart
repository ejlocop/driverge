import 'package:driverge/blocs/bloc/app_bloc.dart';
import 'package:driverge/models/contact.dart';
import 'package:driverge/models/log.dart';
import 'package:driverge/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:telephony/telephony.dart';

class ContactsListBuilder extends StatefulWidget {
	const ContactsListBuilder(
		{Key? key,
		this.future,
		this.onDelete,
		this.showDelete,
		this.showCall}) : super(key: key);

	final Future<List<Contact>>? future;

	final bool? showDelete;
	final bool? showCall;
	final Function(Contact)? onDelete;

	@override
	ContactsListBuilderState createState() => ContactsListBuilderState();
}

class ContactsListBuilderState extends State<ContactsListBuilder> {
	
	final telephony = Telephony.instance;
	List<Contact> _contacts = [];

	void _callContact(Contact contact) async {
		await telephony.dialPhoneNumber(contact.phone);
	}

	@override
	Widget build(BuildContext context) {
		return FutureBuilder<List<Contact>>(
			future: widget.future,
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
				
				_contacts = BlocProvider.of<AppBloc>(context).state.contacts;

				if(widget.future != null) {
					_contacts = snapshot.data!;
				}

				BlocProvider.of<AppBloc>(context).add(ContactsLoaded(_contacts, true));

				if (_contacts.isEmpty) {
					return const Center(
						child: Text('No contacts found'),
					);
				}

				return BlocListener<AppBloc, AppState>(
					listener: (context, state) {
						if(_contacts.length != state.contacts.length) {
							setState(() => _contacts = state.contacts);
						}
					},
					child: ListView.builder(
						itemCount: _contacts.length,
						itemBuilder: (context, index) => _buildContactCard(_contacts[index], context)
					),
				);
			}
		);
	}

	Widget _buildContactCard(Contact contact, BuildContext context) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 15.0),
			child: Card(
				elevation: 2,
				child: Padding(
					padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
					child: Row(
						children: <Widget>[
							_buildContactInfo(contact),
							_buildCallButton(contact),
							_buildDeleteButton(contact, context),
						],
					),
				),
			)
		);
	}

	Widget _buildContactInfo(Contact contact) {
		return Expanded(
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(contact.name,
						style: const TextStyle(
							fontSize: 16.0,
							fontWeight: FontWeight.w800,
						)
					),
					const SizedBox(height: 5),
					Text(
						contact.phone,
						style: TextStyle(
							fontSize: 14.0,
							color: Colors.grey.shade500,
							fontWeight: FontWeight.w400,
						),
					),
				],
			),
		);
	}

	Widget _buildCallButton(Contact contact) {
		return Visibility(
			visible: widget.showCall ?? false,
			child: InkWell(
				onTap: () {
					_callContact(contact);
					LogService.logContact(contact, LogContactType.call);
				},
				borderRadius: BorderRadius.circular(12),
				splashColor: Colors.indigoAccent.shade200,
				child: const Padding(
					padding: EdgeInsets.all(10),
					child: Icon(Icons.call, color: Colors.indigo),
				),
			)
		);
	}

	Widget _buildDeleteButton(Contact contact, BuildContext context) {
		return Visibility(
			visible: widget.showDelete ?? false,
			child: InkWell(
				onTap: () async {
					BlocProvider.of<AppBloc>(context).add(RemovedContact(contact));
					
					await LogService.logContact(contact, LogContactType.delete);
					widget.onDelete!(contact);
				},
				borderRadius: BorderRadius.circular(12),
				splashColor: Colors.red.shade200,
				child: const Padding(
					padding: EdgeInsets.all(10),
					child: Icon(Icons.delete, color: Colors.red),
				),
			)
		);
	}
}
