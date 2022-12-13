part of 'blocker_bloc.dart';

abstract class BlockerEvent {
	const BlockerEvent();
}

class EnableBlockerEvent extends BlockerEvent {
	final bool isBlocked;
	const EnableBlockerEvent(this.isBlocked);
}