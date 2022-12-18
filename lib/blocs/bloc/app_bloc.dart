import 'package:bloc/bloc.dart';
import 'package:driverge/models/contact.dart';
import 'package:driverge/models/message.dart';
import 'package:driverge/models/nav.dart';
import 'package:equatable/equatable.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
	AppBloc() : super(const AppState()) {
		on<NavigateTo>(onNavigateTo);
    
		on<EnableBlockerEvent>(onEnabledBlocker);

		on<AddNewContact>(onAddNewContact);
		on<RemovedContact>(onRemovedContact);
		on<ContactsLoaded>(onContactsLoaded);

		on<AddNewMessage>(onAddNewMessage);
		on<RemovedMessage>(onRemovedMessage);
		on<MessagesLoaded>(onMessagesLoaded);
		on<MessageSelected>(onMessageSelected);
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

	void onContactsLoaded(ContactsLoaded event, Emitter<AppState> emit) {
		emit(state.copyWith(contacts: event.contacts, contactsFetched: event.contactsFetched));
	}

	void onRemovedContact(RemovedContact event, Emitter<AppState> emit) {
		emit(state.copyWith(contacts: state.contacts.where((contact) => contact.id != event.contact.id).toList()));
	}

	void onAddNewMessage(AddNewMessage event, Emitter<AppState> emit) {
		emit(state.copyWith(messages: [...state.messages, event.message]));
	}

	void onMessagesLoaded(MessagesLoaded event, Emitter<AppState> emit) {
		emit(state.copyWith(messages: event.messages, messagesFetched: event.messagesFetched));
	}

	void onRemovedMessage(RemovedMessage event, Emitter<AppState> emit) {
		emit(state.copyWith(messages: state.messages.where((message) => message.id != event.message.id).toList()));
	}

  void onMessageSelected(MessageSelected event, Emitter<AppState> emit) {
    emit(state.copyWith(selectedMessageId: event.selectedMessageId));
  }
}
