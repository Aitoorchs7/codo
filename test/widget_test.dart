import 'package:codo/app/app_routes.dart';
import 'package:codo/utils/startup_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('startupRoute goes to home when there is a session', () {
    expect(
      startupRoute(signedIn: true, onboardingSeen: true),
      AppRoutes.home,
    );
  });

  test('startupRoute skips onboarding when signed in, even if not seen', () {
    expect(
      startupRoute(signedIn: true, onboardingSeen: false),
      AppRoutes.home,
    );
  });

  test('startupRoute goes to onboarding on first launch without session', () {
    expect(
      startupRoute(signedIn: false, onboardingSeen: false),
      AppRoutes.onboarding,
    );
  });

  test('startupRoute goes to login when onboarding was seen but no session', () {
    expect(
      startupRoute(signedIn: false, onboardingSeen: true),
      AppRoutes.login,
    );
  });
}
