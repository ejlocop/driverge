part of 'blocker_bloc.dart';

class BlockerState extends Equatable {
	final bool isBlocked;

	const BlockerState(this.isBlocked);

	factory BlockerState.initial() => const BlockerState(false);

	@override
	List<Object?> get props => [isBlocked];

	BlockerState copyWith(bool? isBlocked) {
		return BlockerState(
			isBlocked ?? this.isBlocked
		);
	}
}

