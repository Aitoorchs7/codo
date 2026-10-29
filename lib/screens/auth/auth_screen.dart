import 'package:codo/admins/auth_failure.dart';
import 'package:codo/admins/auth_service.dart';
import 'package:codo/app/app_routes.dart';
import 'package:codo/app/codo_colors.dart';
import 'package:codo/models/profile.dart';
import 'package:codo/repositories/profile_repository.dart';
import 'package:codo/screens/auth/auth_messages.dart';
import 'package:codo/widgets/login_video_background.dart';
import 'package:codo/widgets/codo_mode_switch.dart';
import 'package:codo/widgets/glass_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:codo/app/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _profiles = ProfileRepository();
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true; // true = entrar, false = crear cuenta
  bool _loading = false; // true mientras esperamos a Firebase
  bool _success = false; // true un instante tras entrar bien: se ve el check
  bool _obscure = true; // true = contraseña oculta
  AuthError? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Escribe tu correo.';
    if (!text.contains('@')) return 'El correo no tiene un formato válido.';
    return null;
  }

  String? _validatePassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Escribe tu contraseña.';
    if (!_isLogin && text.length < 6) return 'Mínimo 6 caracteres.';
    return null;
  }

  // Errores del servidor que se pintan debajo de un campo concreto.
  String? get _emailServerError => switch (_error) {
    AuthError.emailInUse || AuthError.invalidEmail => authErrorMessage(_error!),
    _ => null,
  };

  String? get _passwordServerError =>
      _error == AuthError.weakPassword ? authErrorMessage(_error!) : null;

  // El resto de errores van en el aviso de arriba.
  bool get _showBanner =>
      _error != null &&
      _emailServerError == null &&
      _passwordServerError == null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (_isLogin) {
        await _auth.signIn(email, password);
      } else {
        await _auth.register(email, password);
        await _profiles.saveProfile(
          Profile(
            uid: FirebaseAuth.instance.currentUser!.uid,
            displayName: email.split('@').first,
            xp: 0,
            medals: [],
            createdAt: DateTime.now(),
          ),
        );
      }
      if (!mounted) return;
      // Un momento con el check a la vista antes de entrar.
      setState(() => _success = true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() => _error = e.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;        // primero se enseña la carga
      _error = null;
    });
    try {
      final user = await _auth.signInWithGoogle();
      // Si es nuevo se crea el perfil; si ya existía se recupera
      await _profiles.getOrCreateProfile(
        uid: user.uid,
        displayName: user.displayName ?? 'Usuario',
        photoUrl: user.photoURL,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    } on AuthFailure catch (e) {
      // Cancelar no es un error: se vuelve a la pantalla sin aviso
      if (!mounted || e.error == AuthError.cancelled) return;
      setState(() => _error = e.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setMode(int index) {
    if (_loading) return;
    setState(() {
      _isLogin = index == 0;
      _error = null;
    });
  }

  // Al escribir, el error del servidor deja de tener sentido.
  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<CodoColors>()!;
    return Scaffold(
      body: LoginVideoBackground(
        child: SafeArea(
          // La hoja de abajo llega hasta el borde de la pantalla.
          bottom: false,
          // Con scroll para que el teclado no tape el formulario.
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                          child: _Entrance(
                            duration: const Duration(milliseconds: 500),
                            child: _buildHeader(
                              AppTheme.dark.textTheme,
                              CodoColors.dark,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _Entrance(
                          offset: 60,
                          duration: const Duration(milliseconds: 700),
                          child: _buildSheet(c),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme, CodoColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset('assets/images/logo.png', width: 44),
            const SizedBox(width: 10),
            Text('codo', style: textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 32),
        // El título y el subtítulo se funden al cambiar de modo.
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.topLeft,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topLeft,
              children: [...previous, ?current],
            ),
            child: Column(
              key: ValueKey(_isLogin),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    _isLogin ? 'Hola de nuevo' : 'Crea tu cuenta',
                    style: textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Entra para ver quién está haciendo cosas a tu codo.'
                      : 'Un minuto y empiezas a cumplir acompañado.',
                  style: textTheme.bodyLarge?.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSheet(CodoColors c) {
    final busy = _loading || _success;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: c.surfaceSolid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: c.surfaceCardBorder),
      ),
      child: Form(
        key: _formKey,
        // AnimatedSize: la hoja crece y encoge suave al aparecer errores.
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CodoModeSwitch(
                labels: const ['Entrar', 'Crear cuenta'],
                selected: _isLogin ? 0 : 1,
                onChanged: _setMode,
              ),
              const SizedBox(height: 20),
              if (_showBanner) ...[
                // El icono evita depender solo del color; liveRegion hace que
                // el lector de pantalla lo lea al aparecer.
                Semantics(
                  liveRegion: true,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.track,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.error, width: 2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline, color: c.error),
                        const SizedBox(width: 12),
                        Expanded(child: Text(authErrorMessage(_error!))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _emailController,
                enabled: !busy,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                forceErrorText: _emailServerError,
                onChanged: (_) => _clearError(),
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                enabled: !busy,
                obscureText: _obscure,
                textInputAction: TextInputAction.done,
                forceErrorText: _passwordServerError,
                onChanged: (_) => _clearError(),
                onFieldSubmitted: (_) {
                  if (!busy) _submit();
                },
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  helperText: _isLogin ? null : 'Mínimo 6 caracteres.',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _obscure
                        ? 'Mostrar contraseña'
                        : 'Ocultar contraseña',
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 24),
              GlassButton(
                primary: true,
                onPressed: busy ? null : _submit,
                // El contenido del botón cambia con una transición suave:
                // texto → rueda de carga → check.
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: _buildButtonContent(),
                ),
              ),
              const SizedBox(height: 12),
              GlassButton(
                onPressed: busy ? null : _signInWithGoogle,
                child: const Text('Continuar con Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (_success) {
      return const Icon(
        Icons.check,
        key: ValueKey('ok'),
        color: CodoColors.onAccent,
      );
    }
    if (_loading) {
      return const SizedBox(
        key: ValueKey('loading'),
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: CodoColors.onAccent,
          semanticsLabel: 'Cargando',
        ),
      );
    }
    return Text(_isLogin ? 'Entrar' : 'Crear cuenta', key: ValueKey(_isLogin));
  }
}

// Entrada suave: el contenido aparece subiendo desde abajo mientras se hace
// visible. TweenAnimationBuilder lo anima solo, sin controller.
class _Entrance extends StatelessWidget {
  const _Entrance({
    required this.child,
    this.offset = 40,
    this.duration = const Duration(milliseconds: 600),
  });

  final Widget child;
  final double offset;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, offset * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
