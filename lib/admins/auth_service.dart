/* clase para comprobar si el usuario ya esta
registrado o debe hacerlo y en caso de que quiera cerrar sesión
pasa por aquí también */
import 'package:codo/admins/auth_failure.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges(); // devuelve en el estado que esta el usuario, si hay cuenta o no
  //metodo que prueba iniciar sesión, si no hay usuario lanza authFailure de tipo unknown
  Future<User> signIn(String email,String password) async{
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //credenciales del usuario se mandan a firebase
      final user = cred.user;
      if (user == null) throw const AuthFailure(AuthError.unknown);
      return user;
    } on FirebaseAuthException catch (e) {
      //la función _mapError elige dependiendo del error un tipo de fallo u otra con un switch
      throw AuthFailure(_mapError(e.code));
    }
  }


  Future<User> register(String email, String password) async{
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if(user == null) throw const AuthFailure(AuthError.unknown);
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapError(e.code));
    }

  }
  Future<void> signOut() => _auth.signOut();

  AuthError _mapError(String code) {
    return switch (code) {
      'invalid-credential' || 'wrong-password' || 'user-not-found' =>
      AuthError.invalidCredentials,
      'email-already-in-use' => AuthError.emailInUse,
      'weak-password' => AuthError.weakPassword,
      'invalid-email' => AuthError.invalidEmail,
      'user-disabled' => AuthError.userDisabled,
      'too-many-requests' => AuthError.tooManyRequests,
      'network-request-failed' => AuthError.networkRequestFailed,
      _ => AuthError.unknown,
    };
  }
}