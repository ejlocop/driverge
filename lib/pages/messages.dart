import 'package:driverge/blocs/bloc/app_bloc.dart';
import 'package:driverge/models/message.dart';
import 'package:driverge/services/database.dart';
import 'package:driverge/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagesPage extends StatefulWidget {
	const MessagesPage({super.key});

	@override
	MessagesPageState createState() => MessagesPageState();
}

class MessagesPageState extends State<MessagesPage> {
	final _textController = TextEditingController();
	final _formKey = GlobalKey<FormState>();
	final DatabaseService _databaseService = DatabaseService();

	@override
	void initState() {
		super.initState();
	}

	@override
	void dispose() {
		_textController.dispose();
		super.dispose();
	}

	Future<List<Message>> _getMessages() async {
		return await _databaseService.messages();
	}

	Future _addMessage(Message message) async {
		await _databaseService.inserMessage(message);
		setState(() {});
	}

	Future _deleteMessage(Message message) async {
		await _databaseService.deleteMessage(message.id!);
		setState(() {});
	}

	@override
	Widget build(BuildContext context) {
		final bool wasMessagesFetched = BlocProvider.of<AppBloc>(context).state.messagesFetched;
		
		return Column(
			children: <Widget>[
				_buildForm(),
				const Divider(height: 20),
				// Expanded(
					// child: MessagesListBuilder(
					// 	future: _getMessages(),
					// 	showDelete: true,
					// 	onDelete: _deleteMessage
					// )
				// )
			]
		);
	}

	Widget _buildForm() {
		return Form(
			key: _formKey,
			child: Column(
				children: <Widget> [
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 20), 
						child: TextFormField(
							controller: _textController,
							decoration: const InputDecoration(hintText: 'Text'),
							keyboardType: TextInputType.text,
							validator: (value) {
								return (value == null || value.isEmpty)
										? 'Please enter a text'
										: null;
							},
						),
					),
					const SizedBox(height: 20),
					BlocBuilder<AppBloc, AppState>(
						builder: (context, state) {
							return ElevatedButton(
								onPressed: () {
									if (_formKey.currentState!.validate()) {
										final message = Message(
											id: state.contacts.length + 1,
											text: _textController.text,
										);

										_onMessageAdded(message, context);
									}
								},
								child: const Text('Add emergency contact')
							);
						},
					)
				]
			),
		);
	}

	void _onMessageAdded(Message message, BuildContext context) async {
		ScaffoldMessenger.of(context)
			.showSnackBar(const SnackBar(content: Text('Message Added')));
			
		_addMessage(message);

		BlocProvider.of<AppBloc>(context).add(AddNewMessage(message));

		FocusScope.of(context).requestFocus(FocusNode());

    await LogService.logMessage(message, LogMessageType.add);

		_textController.clear();
	}
}
