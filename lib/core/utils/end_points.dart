class EndPoints {
  EndPoints._();

  static const String _base = '/api/v1';

  static const String staffLogin   = '$_base/auth/staff/login';
  static const String staffMe      = '$_base/auth/staff/me';
  static const String refreshToken = '$_base/auth/refresh';

  static const String branches     = '$_base/branches';
  static const String orders       = '$_base/orders';
  static const String products     = '$_base/products';
  static const String customers    = '$_base/customers';
}
