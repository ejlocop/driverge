import 'package:bloc/bloc.dart';
import 'package:driverge/models/contact.dart';
import 'package:driverge/models/nav.dart';
import 'package:equatable/equatable.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
	AppBloc() : super(const AppState()) {
		on<NavigateTo>(onNavigateTo);
		on<EnableBlockerEvent>(onEnabledBlocker);
		on<AddNewContact>(onAddNewContact);
	}

	void onNavigateTo(NavigateTo event, Emitter<AppState> emit) {
		emit(state.copyWith(selectedItem: event.destination));
	}

	void onEnabledBlocker(EnableBlockerEvent event, Emitter<AppState> emit) {
		emit(state.copyWith(isBlocked: event.isBlocked));
	}

	void onAddNewContact(AddNewContact event, Emitter<AppState> emit) {
		emit(state.copyWith(contacts: [...state.contacts, event.contact]));
	}

	void onFetchAllContacts(FetchedAllContacts event, Emitter<AppState> emit) {
		emit(state.copyWith(contacts: event.contacts));
	}
}
