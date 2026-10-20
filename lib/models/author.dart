class Author {
  final int id;
  final String lastName;
  final String firstName;
  final String middleName;
  final String country;
  final int birthYear;
  final DateTime? deletedAt;

  const Author({
    required this.id,
    required this.lastName,
    required this.firstName,
    this.middleName = '',
    required this.country,
    required this.birthYear,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  String get fullName => [lastName, firstName, middleName]
      .where((part) => part.isNotEmpty)
      .join(' ');

  String get shortName {
    final initials = [firstName, middleName]
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0]}.')
        .join(' ');
    return initials.isEmpty ? lastName : '$lastName $initials';
  }

  Author copyWith({
    int? id,
    String? lastName,
    String? firstName,
    String? middleName,
    String? country,
    int? birthYear,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Author(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      country: country ?? this.country,
      birthYear: birthYear ?? this.birthYear,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
