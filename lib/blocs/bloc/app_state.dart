part of 'app_bloc.dart';

class AppState extends Equatable {

	final bool isBlocked;
	final NavItem selectedItem;
	final List<Contact> contacts;
	
	const AppState({
		this.isBlocked = false,
		this.selectedItem = NavItem.homePage,
		this.contacts = const [],
	});
	
	@override
	List<Object> get props => [
		isBlocked,
		selectedItem,
		contacts
	];

	AppState copyWith({
		bool? isBlocked,
		NavItem? selectedItem,
		List<Contact>? contacts,
	}) {
		return AppState(
			isBlocked: isBlocked ?? this.isBlocked,
			selectedItem: selectedItem ?? this.selectedItem,
			contacts: contacts ?? this.contacts,
		);
	}
}
