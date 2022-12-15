part of 'app_bloc.dart';

class AppState extends Equatable {

	final bool isBlocked;
	final NavItem selectedItem;
	final List<Contact> contacts;
	final bool contactsFetched;
	
	const AppState({
		this.isBlocked = false,
		this.selectedItem = NavItem.homePage,
		this.contacts = const [],
		this.contactsFetched = false,
	});
	
	@override
	List<Object> get props => [
		isBlocked,
		selectedItem,
		contacts,
		contactsFetched,
	];

	AppState copyWith({
		bool? isBlocked,
		NavItem? selectedItem,
		List<Contact>? contacts,
		bool? contactsFetched,
	}) {
		return AppState(
			isBlocked: isBlocked ?? this.isBlocked,
			selectedItem: selectedItem ?? this.selectedItem,
			contacts: contacts ?? this.contacts,
			contactsFetched: contactsFetched ?? this.contactsFetched
		);
	}
}
