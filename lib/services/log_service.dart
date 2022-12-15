
import 'package:driverge/models/contact.dart';
import 'package:driverge/models/log.dart';
import 'package:driverge/models/message.dart';
import 'package:driverge/services/database.dart';

class LogService {
	static Future<void> logContact(Contact contact, LogContactType logType) async {
		await DatabaseService().insertLog(Log(
			type: 'contact',
			message: '${_getLogContactTypeVerb(logType)} $contact'
		));
	}

	static Future<void> logMessage(Message message, LogMessageType logType) async {
		await DatabaseService().insertLog(Log(
			type: 'message',
			message: '${_getLogMessageTypeVerb(logType)} $message'
		));
	}

	static Future<void> logBlocking(bool isBlocking) async {
		final verb = isBlocking ? 'Enabled' : 'Disabled';
		await DatabaseService().insertLog(Log(
			type: 'blocking',
			message: '$verb blocking'
		));
	}

	static String _getLogContactTypeVerb(LogContactType logType) {
		switch(logType) {
			case LogContactType.delete:
				return 'Deleted';
			case LogContactType.call:
				return 'Called';
			default:
				return 'Added';
		}
	}

	static String _getLogMessageTypeVerb(LogMessageType logType) {
		switch(logType) {
			case LogMessageType.delete:
				return 'Deleted';
			default:
				return 'Added';
		}
	}
}