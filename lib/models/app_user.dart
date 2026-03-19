enum UserRole { owner, admin, inspector }

class AppUser {
  final String id;
  final String email;
  final UserRole role;
  final String? organizationId;
  final String? organizationName;
  final String? fullName;
  final String? siape;

  const AppUser({
    required this.id,
    required this.email,
    required this.role,
    this.organizationId,
    this.organizationName,
    this.fullName,
    this.siape,
  });

  static UserRole roleFromDb(String role) {
    switch (role) {
      case 'owner':
        return UserRole.owner;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.inspector;
    }
  }
}

