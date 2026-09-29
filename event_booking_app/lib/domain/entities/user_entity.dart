class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
  });

  bool get isAdmin => role == 'admin';
  bool get isOrganizer => role == 'organizer' || role == 'admin';
}
