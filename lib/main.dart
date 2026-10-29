import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codo/app/app.dart';
import 'package:codo/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';


//El main es asíncrono porque tiene que esperar la respuesta del firestore conectarse
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  /* Esto sirve para crear el puente entre las distintas plataformas como firebase
  para que no de error al ejecutar el app */
  await Firebase.initializeApp(
    //currentPlatform nos da la plataforma actual y nos conecta con ella
      options: DefaultFirebaseOptions.currentPlatform,
  );
  //si no se usa el emulador, no se conecta
  const useEmulators = bool.fromEnvironment('USE_EMULATORS');
  if (useEmulators) {
    final host = (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) ? '10.0.2.2' : 'localhost';
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  }
  if (!kIsWeb) await GoogleSignIn.instance.initialize();
  /* inicializamos el firebase para que pueda funcionar al iniciarse la app
  necesitamos un proveedor que guarda los objetos
  que comparten varias clases para no estar cambiando variables
  en cada clase. */
  runApp(const App());
}


