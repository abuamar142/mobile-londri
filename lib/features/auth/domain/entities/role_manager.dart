class RoleManager {
  RoleManager._();

  static UserRole? _currentUserRole;

  static final Map<UserRole, List<Permission>> rolePermissions = {
    UserRole.superAdmin: [
      Permission.manageUserRoles,
      Permission.manageServices,
      Permission.manageTransactions,
    ],
    UserRole.admin: [
      Permission.manageUserRoles,
      Permission.manageServices,
      Permission.manageTransactions,
    ],
    UserRole.user: [
      Permission.manageTransactions,
    ],
  };

  static bool hasPermission(Permission permission) {
    final userRole = _currentUserRole;
    if (userRole == null) return false;

    return rolePermissions[userRole]?.contains(permission) ?? false;
  }

  static void setUserRole(String role) {
    _currentUserRole = getUserRoleFromString(role);
  }

  static UserRole? get currentUserRole => _currentUserRole;

  static UserRole? getUserRoleFromString(String? role) {
    switch (role) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'admin':
        return UserRole.admin;
      case 'user':
        return UserRole.user;
      default:
        return null;
    }
  }
}

enum Permission {
  manageTransactions,
  manageUserRoles,
  manageServices,
}

enum UserRole {
  superAdmin,
  admin,
  user,
}
