//clase para controlar las preferecias del usuario
//para ver lo que ha hecho, lo que no tiene  o lo que no permite
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesAdmin {

  static const _onboardingSeenKey = 'onboarding_seen';

  // metodos para ver si la pantalla se ha visto y si no, hacer que se haya visto
  // estos datos estan en shared_preferences del dispositivo que se guardan en disco
  Future<bool> isOnboardingSeen(bool onboardingSeen) async{
    // cogemos las preferencias del dispositivo
    final prefs = await SharedPreferences.getInstance();
    // vemos si ya se ha visto la pantalla
    final seen = prefs.getBool('onboarding_seen') ?? false;
    return seen;
  }
  Future<void> markAsOnboardingSeen() async {
    // tenemos que ver otra vez la preferencia para tener la variable
    // aunque este metodo solo se ejecuta si la variable ya estaba en false
    final prefs = await SharedPreferences.getInstance();
    // cambiamos la preferencia del dispositivo para que haya visto la pantalla
    await prefs.setBool(_onboardingSeenKey, true);
  }
}