/* en caso de que alguna de las autentificaciones de
auth_service falle, aquí las recogemos del try catch
y tomamos la decision, es decir, creamos la excepción
 */
enum AuthError { invalidCredentials, emailInUse, weakPassword, unknown, invalidEmail, userDisabled, tooManyRequests, networkRequestFailed}

class AuthFailure implements Exception {
  final AuthError error;
  const AuthFailure(this.error);

}
