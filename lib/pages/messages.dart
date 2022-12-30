import 'package:driverge/blocs/bloc/app_bloc.dart';
import 'package:driverge/models/message.dart';
import 'package:driverge/services/database.dart';
import 'package:driverge/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

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
	late int selectedMessageId;
	late bool isBlocked;

	@override
	void initState() {
		super.initState();
		selectedMessageId = BlocProvider.of<AppBloc>(context).state.selectedMessageId;
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
		isBlocked = BlocProvider.of<AppBloc>(context).state.isBlocked;

		return Column(
			children: <Widget>[
				_buildForm(),
				const Divider(height: 20),
				const Padding(
					padding: EdgeInsets.all(20),
					child: Text(
						'Select a message that you want be automatically sent to the texter/caller.',
						style: TextStyle(fontSize: 16),
					),
				),
				Expanded(
					child: FutureBuilder<List<Message>>(
						future: wasMessagesFetched ? null : _getMessages(),
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
							
							_messages = BlocProvider.of<AppBloc>(context).state.messages;

							if(!wasMessagesFetched) {
								_messages = snapshot.data!;
								BlocProvider.of<AppBloc>(context)
										.add(MessageSelected(_messages[0].id!));
							}

							BlocProvider.of<AppBloc>(context)
									.add(MessagesLoaded(_messages, true));

							if (_messages.isEmpty) {
								return const Center(
									child: Text('No messages found'),
								);
							}

							return BlocListener<AppBloc, AppState>(
								listener: (context, state) {
									setState(() {
										selectedMessageId = state.selectedMessageId;
									});
								},
								child: ListView.builder(
									itemCount: _messages.length,
									itemBuilder: (context, index) => _buildMessageCard(_messages[index], index, context)
								),
							);
						}
					)
				)
			]	
		);
	}

	Widget _buildMessageCard(Message message, int messageIndex, BuildContext context) {
		final bool isSelected = selectedMessageId != message.id;
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 15),
			child: Card(
				elevation: 2,
				child: Padding(
					padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
					child: Row(
						children: <Widget> [
							Expanded(child: Text(message.text)),
							InkWell(
								onTap: () async {
									
									if(isBlocked) {
										if(!(await confirm(context, 
											content: const Text('Blocking of calls/SMS will be disabled when you change the default message. Do you want to continue?'), 
											textOK: const Text('Yes'), 
											textCancel: const Text('No')
										))) {
											
											return;
										}
									}
									
									setState(() {
										isBlocked = false;
									});
									BlocProvider.of<AppBloc>(context).add(EnableBlockerEvent(false));
									BlocProvider.of<AppBloc>(context).add(MessageSelected(message.id!));
								},
								borderRadius: BorderRadius.circular(12),
								splashColor: Colors.indigoAccent.shade200,
								child: Padding(
									padding: const EdgeInsets.all(10),
									child: Icon(
										!isSelected ? Icons.radio_button_checked_sharp : Icons.radio_button_off_sharp, 
										color: isSelected ? Colors.grey.shade300 : Colors.indigo
									),
								),
							),
							InkWell(
								onTap: () async {
									BlocProvider.of<AppBloc>(context).add(RemovedMessage(message));

									BlocProvider.of<AppBloc>(context).add(MessageSelected(-1));

									await LogService.logMessage(message, LogMessageType.delete);

									_deleteMessage(message);
								},
								borderRadius: BorderRadius.circular(12),
								splashColor: Colors.red.shade200,
								child: const Padding(
									padding: EdgeInsets.all(10),
									child: Icon(Icons.delete, color: Colors.red),
								),
							)
						],
					), 
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
		ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message Added')));

		_addMessage(message);

		BlocProvider.of<AppBloc>(context).add(AddNewMessage(message));

		FocusScope.of(context).requestFocus(FocusNode());

		await LogService.logMessage(message, LogMessageType.add);

		_textController.clear();
	}
}
