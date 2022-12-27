import 'package:driverge/blocs/bloc/app_bloc.dart';

class Commands {
	late List<String> _commands = [];
	AppBloc bloc;

	Commands({required this.bloc});

	void initializeCommands() {
		final _mapping = [
      "enable",
      "disable",
      "toggle",
		];
		_commands.addAll(_mapping);
	}

	void handle (String command) {
		_determineBlocking(command);
	}

	_determineBlocking(String command) {
		if(command.contains("enable") && !bloc.state.isBlocked) {
			bloc.add(EnableBlockerEvent(true));
		}
		else if(command.contains("disable") && bloc.state.isBlocked) {
			bloc.add(EnableBlockerEvent(false));
		}
		else if(command.contains("toggle")) {
			bloc.add(EnableBlockerEvent(bloc.state.isBlocked ? false : true));
		}
		else {
			throw new UnknownCommandException("Unknown command: $command");
		}
	}
}

class UnknownCommandException implements Exception {
	final String? message;
	const UnknownCommandException([this.message]);

	@override
	String toString() {
		String result = 'UnknownCommandException';
		if (message is String) return '$result: $message';
		return result;
	}
}