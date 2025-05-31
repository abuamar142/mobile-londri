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
      Permission.accessMainMenu,
    ],
    UserRole.admin: [
      Permission.manageCustomers,
      Permission.manageTransactions,
      Permission.accessMainMenu,
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
  accessMainMenu,
}

enum UserRole {
  superAdmin(value: 'Super Admin'),
  admin(value: 'Admin'),
  user(value: 'User');

  final String value;

  const UserRole({
    required this.value,
  });
}
