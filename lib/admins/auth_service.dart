/* clase para comprobar si el usuario ya esta
registrado o debe hacerlo y en caso de que quiera cerrar sesión
pasa por aquí también */
import 'package:codo/admins/auth_failure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      'popup-closed-by-user' || 'cancelled-popup-request' => AuthError.cancelled,
      _ => AuthError.unknown,
    };
  }
  Future<User> signInWithGoogle() async {
    try {
        final UserCredential cred;
        if(kIsWeb){
          // Si el usuario esta en web abre la ventana emergente de google
          cred = await _auth.signInWithPopup(GoogleAuthProvider());
        }else{
          final account = await GoogleSignIn.instance.authenticate();
          final idToken = account.authentication.idToken;
          // con el token firebase crea o recupera el usuario
          cred = await _auth.signInWithCredential(
            GoogleAuthProvider.credential(idToken: idToken,),
          );
        }
        final user = cred.user;
        if(user == null) throw const AuthFailure(AuthError.unknown);
        return user;
    } on GoogleSignInException catch (e) {
      throw AuthFailure(e.code == GoogleSignInExceptionCode.canceled?
      AuthError.cancelled
          :
      AuthError.unknown);
    } on FirebaseAuthException catch (e) {
      //la función _mapError elige dependiendo del error un tipo de fallo u otra con un switch
      throw AuthFailure(_mapError(e.code));
    }
  }

  // Guardamos el estado de sesión del usuario actual
  //si no hay usuario devuelve null
  Future<User?> currentUser() => authStateChanges.first;
}
