
import 'package:driverge/models/contact.dart';
import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

class ContactsListBuilder extends StatelessWidget {
	
	ContactsListBuilder({
		Key? key,
		required this.future,
		this.onEdit,
		this.onDelete,
		this.showDelete,
		this.showEdit,
		this.showCall
	}) : 
		// assert(showDelete != true || onDelete == null),
		// assert(showEdit != true || onEdit == null),
		super(key: key);

	final Future<List<Contact>> future;

	final bool? showDelete;
	final bool? showEdit;
	final bool? showCall;
	final Function(Contact)? onEdit;
	final Function(Contact)? onDelete;
	final telephony = Telephony.instance;
	
	void _callContact(Contact contact) async {
		await telephony.openDialer(contact.phone);
	}

	@override
	Widget build(BuildContext context) {
		return FutureBuilder<List<Contact>>(
			future: future,
			builder: (context, snapshot) {
				if(snapshot.connectionState == ConnectionState.waiting) {
					return const Center(
						child: CircularProgressIndicator(),
					);
				}
				return ListView.builder(
					itemCount: snapshot.data!.length,
					itemBuilder: (context, index) => _buildContactCard(snapshot.data![index], context)
				);
			}
		);
	}

	Widget _buildContactCard (Contact contact, BuildContext context) {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10.0),
			child: Card(
				child: Padding(
					padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
					child: Row(
						children: <Widget>[
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											contact.name,
											style: const TextStyle(
												fontSize: 16.0,
												fontWeight: FontWeight.w800,
											)
										),
										const SizedBox(height: 1),
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
							),
							Visibility(
								visible: showCall ?? false,
								child: InkWell(
									onTap: () => _callContact(contact),
									borderRadius: BorderRadius.circular(12),
									splashColor: Colors.indigoAccent.shade200,
									child: const Padding(
										padding: EdgeInsets.all(10),
										child: Icon(Icons.call, color: Colors.indigo),
									),
								)
							),
							Visibility(
								visible: showEdit ?? false,
								child: Column(
									children: [
										const SizedBox(width: 50.0),
										InkWell(
											onTap: () => onEdit!(contact),
											borderRadius: BorderRadius.circular(12),
											splashColor: Colors.indigoAccent.shade200,
											child: const Padding(
												padding: EdgeInsets.all(10),
												child: Icon(Icons.edit, color: Colors.indigo),
											),
										)
									]
								),
							),
							Visibility(
								visible: showDelete ?? false,
								child: InkWell(
									onTap: () => onDelete!(contact),
									borderRadius: BorderRadius.circular(12),
									splashColor: Colors.red.shade200,
									child: const Padding(
										padding: EdgeInsets.all(10),
										child: Icon(Icons.delete, color: Colors.red),
									),
								)
							)
						],
					),
				),
			)
		);
	}
}