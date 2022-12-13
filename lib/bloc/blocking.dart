import 'package:bloc/bloc.dart';

class BlockingBloc extends Bloc<BlockingEvent, BlockingEnabledState> {
	BlockingBloc() : super(const BlockingEnabledState(false)) {
		on<SetEnabled>((event, emit) {
			if (event.isEnabled != state.isEnabled) {
				emit(BlockingEnabledState(state.isEnabled));
			}
		});
	}
}

abstract class BlockingEvent {
	const BlockingEvent();
}

class SetEnabled extends BlockingEvent {
	final bool isEnabled;
	const SetEnabled(this.isEnabled);
}

class BlockingEnabledState {
	final bool isEnabled;

	const BlockingEnabledState(this.isEnabled);
}