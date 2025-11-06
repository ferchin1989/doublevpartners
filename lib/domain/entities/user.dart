class User {
  final int? id;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;

  const User({
    this.id,
    required this.firstName,
    required this.lastName,
    this.birthDate,
  });

  User copyWith({int? id, String? firstName, String? lastName, DateTime? birthDate}) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  static const empty = User(id: null, firstName: '', lastName: '', birthDate: null);
}
