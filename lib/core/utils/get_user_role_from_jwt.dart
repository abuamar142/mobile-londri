import 'package:jwt_decoder/jwt_decoder.dart';

extension GetUserRoleFromJwt on String {
  String getUserRoleFromJwt() {
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(this);
    final String? role = decodedToken['user_role'] as String?;

    if (role != null) {
      return role;
    } else {
      return 'user';
    }
  }
}
