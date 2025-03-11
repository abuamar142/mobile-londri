class RoleManager {
  RoleManager._();

  static final Map<UserRole, List<Permission>> rolePermissions = {
    UserRole.superAdmin: [
      Permission.manageUserRoles,
      Permission.manageTransactions,
    ],
    UserRole.admin: [
      Permission.manageUserRoles,
      Permission.manageTransactions,
    ],
    UserRole.user: [
      Permission.manageTransactions,
    ],
  };

  static bool hasPermission(UserRole role, Permission permission) {
    return rolePermissions[role]?.contains(permission) ?? false;
  }

  static List<Permission> getPermissionsForRole(UserRole role) {
    return rolePermissions[role] ?? [];
  }

  static UserRole getUserRole = UserRole.user;
}

enum Permission {
  manageTransactions,
  manageUserRoles,
}

enum UserRole {
  superAdmin,
  admin,
  user,
}
