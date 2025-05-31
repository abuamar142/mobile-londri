class RoleManager {
  RoleManager._();

  static UserRole? _currentUserRole;

  static final Map<UserRole, List<Permission>> rolePermissions = {
    UserRole.superAdmin: [
      Permission.manageStaffs,
      Permission.manageCustomers,
      Permission.manageServices,
      Permission.manageTransactions,
      Permission.hardDeleteTransaction,
      Permission.activateCustomer,
      Permission.hardDeleteCustomer,
      Permission.exportReports,
    ],
    UserRole.admin: [
      Permission.manageCustomers,
      Permission.manageTransactions,
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
  manageStaffs,
  manageCustomers,
  activateCustomer,
  hardDeleteCustomer,
  manageServices,
  manageTransactions,
  hardDeleteTransaction,
  trackTransactions,
  exportReports,
}

enum UserRole {
  superAdmin,
  admin,
  user,
}
