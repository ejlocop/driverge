import 'package:driverge/models/log.dart';
import 'package:driverge/services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogsPage extends StatefulWidget {
	const LogsPage({super.key});

	@override
	LogsPageState createState() => LogsPageState();
}

class LogsPageState extends State<LogsPage> {
	final DatabaseService _databaseService = DatabaseService();
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			floatingActionButton: _buildFloatingButton(context),
			body: FutureBuilder<List<Log>>(
				builder: (context, snapshot) => _buildBody(context, snapshot),
				future: _getAllLogs(),
			),
		);
	}

	Widget _buildFloatingButton (BuildContext context) {
		return FloatingActionButton(
			child: const Icon(Icons.delete_sweep),
			onPressed: () async {
				_deleteLogs();

				ScaffoldMessenger.of(context)
					.showSnackBar(
						const SnackBar(content: Text('Logs deleted')));
			}
		);
	}

	Widget _buildBody(BuildContext context, AsyncSnapshot<List<Log>> snapshot) {
		if(snapshot.connectionState == ConnectionState.waiting) {
			return const Center(
				child: CircularProgressIndicator(),
			);
		}

		if(snapshot.hasError) {
			return Center(
				child: Text('Error: ${snapshot.error}'),
			);
		}

		if(snapshot.data!.isEmpty) {
			return const Center(
				child: Text('No logs'),
			);
		}

		return ListView.builder(
			itemCount: snapshot.data!.length,
			itemBuilder: (context, index) {
				Log log = snapshot.data![index];
				var date = DateFormat("MMM dd, hh:mm a").format(DateTime.parse(log.date!));
        // print(log);
				return ListTile(
					title: Text(log.message, 
						style: const TextStyle(
							fontSize: 16, 
							fontWeight: FontWeight.w600
						)
					),
					subtitle: Text(date),
				);
			},
		);
	}

	Future<List<Log>> _getAllLogs() async {
		return await _databaseService.logs();
	}

	void _deleteLogs() async {
		await _databaseService.deleteLogs();
		setState(() => {});
	}
}
