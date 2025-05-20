abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final String name;
  final String id; 

  UserLoaded(this.name, this.id);
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}
