import 'package:driverge/blocs/bloc/app_bloc.dart';
import 'package:driverge/models/log.dart';
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
	List<Message> _messages = [];

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
		return Column(
			children: <Widget>[
				_buildForm(),
				const Divider(height: 20),
				Expanded(
					child: FutureBuilder<List<Message>>(
						future: _getMessages(),
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

							_messages = snapshot.data!;
							// print(_messages.length);

							BlocProvider.of<AppBloc>(context)
									.add(MessagesLoaded(_messages, true));

							if (_messages.isEmpty) {
								return const Center(
									child: Text('No messages found'),
								);
							}

							return ListView.builder(
								itemCount: _messages.length,
								itemBuilder: (context, index) => _buildMessageCard(_messages[index], context)
							);
						}
					)
				)
			]	
		);
	}

	Widget _buildMessageCard(Message message, BuildContext context) {
		return Card(
			elevation: 2,,
			child: ListTile(
				title: Text(message.text),
				trailing: IconButton(
					icon: const Icon(Icons.delete, color: Colors.red),
					onPressed: () async {
						BlocProvider.of<AppBloc>(context).add(RemovedMessage(message));

						await LogService.logMessage(message, LogMessageType.delete);

						_deleteMessage(message);
					},
				),
			),
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
							// enabled: isFormEnabled,
							controller: _textController,
							decoration: const InputDecoration(hintText: 'Text'),
							keyboardType: TextInputType.text,
							validator: (value) {
								return (value == null || value.isEmpty)
										? 'Please enter a message'
										: null;
							},
						),
					),
					const SizedBox(height: 20),
					ElevatedButton(
						onPressed: () {
							if (_formKey.currentState!.validate()) {
								final message = Message(
									id: _messages.length + 1,
									text: _textController.text,
								);

								_onMessageAdded(message, context);
							}
						},
						child: const Text('Add automated response text')
					),
				]
			)
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
