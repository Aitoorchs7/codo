import 'package:codo/admins/preferences_admin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('isOnboardingSeen returns false on first launch', () async {
    // Simula un móvil donde nunca se ha guardado nada.
    SharedPreferences.setMockInitialValues({});
    expect(await PreferencesAdmin().isOnboardingSeen(), isFalse);
  });

  test('isOnboardingSeen returns true after markAsOnboardingSeen', () async {
    SharedPreferences.setMockInitialValues({});
    final admin = PreferencesAdmin();
    await admin.markAsOnboardingSeen();
    expect(await admin.isOnboardingSeen(), isTrue);
  });

  test('isOnboardingSeen returns false when the stored value is corrupt', () async {
    // El caso malo: alguien guardó un texto donde debería haber un bool.
    SharedPreferences.setMockInitialValues({'onboarding_seen': 'garbage'});
    expect(await PreferencesAdmin().isOnboardingSeen(), isFalse);
  });
}