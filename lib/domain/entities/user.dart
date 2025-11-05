class User {
  final String firstName;
  final String lastName;
  final DateTime? birthDate;

  const User({
    required this.firstName,
    required this.lastName,
    this.birthDate,
  });

  User copyWith({String? firstName, String? lastName, DateTime? birthDate}) {
    return User(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  static const empty = User(firstName: '', lastName: '', birthDate: null);
}
