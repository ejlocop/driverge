import 'package:flutter/cupertino.dart';

class Commands {
	final Map _commands = new Map();

	Commands();

	void initializeCommands() {
		final _mapping = <String, List<String>> {
			"block": ["toggle blocking", "enable blocking", "disable blocking"],
			"contact": ["name", "number"],
		};
		_commands.addAll(_mapping);
	}

	void handle (String command) {
		String _command = _recognizeCommand(command);
		debugPrint("Command: $command");
	}

	_recognizeCommand(String command) {
		if(!_commands.containsKey(command)) {
			throw new UnknownCommandException("Unknown command $command");
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