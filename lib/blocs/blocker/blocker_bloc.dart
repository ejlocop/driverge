import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'blocker_event.dart';
part 'blocker_state.dart';

class BlockerBloc extends Bloc<BlockerEvent, BlockerState> {
	BlockerBloc() : super(BlockerState.initial()) {
		on<EnableBlockerEvent>(_onStatusChange);
	}

	void _onStatusChange(EnableBlockerEvent event, Emitter<BlockerState> emit) {
		print('New Status: ${event.isBlocked}');
		emit(state.copyWith(event.isBlocked));
	}
}
