class RoleManager {
  RoleManager._();

  static UserRole? _currentUserRole;

  static final Map<UserRole, List<Permission>> rolePermissions = {
    UserRole.superAdmin: [
      Permission.manageEmployees,
      Permission.manageCustomers,
      Permission.manageServices,
      Permission.manageTransactions,
      Permission.trackTransactions,
      Permission.activateCustomer,
      Permission.deleteCustomer,
    ],
    UserRole.admin: [
      Permission.manageCustomers,
      Permission.manageTransactions,
      Permission.trackTransactions,
    ],
    UserRole.user: [
      Permission.trackTransactions,
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
  manageEmployees,
  manageCustomers,
  activateCustomer,
  deleteCustomer,
  manageServices,
  manageTransactions,
  trackTransactions,
}

enum UserRole {
  superAdmin,
  admin,
  user,
}
