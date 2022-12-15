part of 'app_bloc.dart';

class AppState extends Equatable {

	final bool isBlocked;
	final NavItem selectedItem;
	final List<Contact> contacts;
	final bool contactsFetched;
	final List<Message> messages;
	final bool messagesFetched;
	
	const AppState({
		this.isBlocked = false,
		this.selectedItem = NavItem.homePage,
		this.contacts = const [],
		this.contactsFetched = false,
		this.messages = const [],
		this.messagesFetched = false,
	});
	
	@override
	List<Object> get props => [
		isBlocked,
		selectedItem,
		contacts,
		contactsFetched,
		messages,
		messagesFetched,
	];

	AppState copyWith({
		bool? isBlocked,
		NavItem? selectedItem,
		List<Contact>? contacts,
		bool? contactsFetched,
		List<Message>? messages,
		bool? messagesFetched,
	}) {
		return AppState(
			isBlocked: isBlocked ?? this.isBlocked,
			selectedItem: selectedItem ?? this.selectedItem,
			contacts: contacts ?? this.contacts,
			contactsFetched: contactsFetched ?? this.contactsFetched,
			messages: messages ?? this.messages,
			messagesFetched: messagesFetched ?? this.messagesFetched
		);
	}
}
