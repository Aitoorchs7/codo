import 'package:codo/app/App.dart';
import 'package:flutter/cupertino.dart';

//El main es asíncrono porque tiene que esperar la respuesta del firestore conectarse
Future<void> main() async {
  const App();

  WidgetsFlutterBinding.ensureInitialized();
  /* Esto sirve para crear el puente entre las distintas plataformas como firebase
  para que no de error al ejecutar el app */
  await Firebase.initializeApp(

  );
  /* inicializamos el firebase para que pueda funcionar al iniciarse la app
  necesitamos un proveedor que guarda los objetos
  que comparten varias clases para no estare cambiando variables
  en cada clase. */
  runApp(const App());


}


