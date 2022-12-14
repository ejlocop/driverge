part of 'app_bloc.dart';

abstract class AppEvent {
	const AppEvent();
}

class NavigateTo extends AppEvent {
	final NavItem destination;
	const NavigateTo(this.destination);
}

class EnableBlockerEvent extends AppEvent {
	final bool isBlocked;
	const EnableBlockerEvent(this.isBlocked);
}

class AddNewContact extends AppEvent {
	final Contact contact;
	const AddNewContact(this.contact);
}

class FetchedAllContacts extends AppEvent {
	final List<Contact> contacts;
	const FetchedAllContacts(this.contacts);
}