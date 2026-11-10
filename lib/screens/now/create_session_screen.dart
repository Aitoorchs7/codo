import 'dart:async';

import 'package:codo/admins/auth_service.dart';
import 'package:codo/models/live_session.dart';
import 'package:codo/repositories/live_session_repository.dart';
import 'package:codo/repositories/profile_repository.dart';
import 'package:codo/repositories/session_failure.dart';
import 'package:codo/screens/now/session_labels.dart';
import 'package:flutter/material.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _repository = LiveSessionRepository();
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _minutes = TextEditingController(text: '60');
  var _category = SessionCategory.study;
  var _public = true;
  var _saving = false;
  final _profiles = ProfileRepository();

  @override
  void dispose() {
    _description.dispose();
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final user = await AuthService().currentUser();
      if (user == null) throw const SessionFailure(SessionError.permissionDenied);
      final name = await _creatorName(user.uid, user.displayName);
      await _repository
          .createSession(LiveSession(
        id: '', // lo pone Firestore
        creatorId: user.uid,
        creatorName: name,
        category: _category,
        description: _description.text.trim(),
        visibility: _public ? SessionVisibility.public : SessionVisibility.friends,
        startedAt: DateTime.now(),
        durationMinutes: int.parse(_minutes.text),
        status: SessionStatus.active,
        participantIds: [user.uid],
      ))
      // Sin red, Firestore guarda la escritura y no responde hasta que vuelve:
      // no dejamos la pantalla esperando para siempre
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      Navigator.pop(context);
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Sin conexión: se publicará al recuperar la red')));
      Navigator.pop(context);
    } on SessionFailure catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.error == SessionError.network
              ? 'Sin conexión. Inténtalo de nuevo'
              : 'No se pudo publicar la sesión')));
    }
  }

  // El nombre sale del perfil (users/{uid}), el mismo que ve el resto de la app.
  // Si no se puede leer (sin red y sin caché), se usa el de la cuenta.
  Future<String> _creatorName(String uid, String? accountName) async {
    String? name;
    try {
      name = (await _profiles.getProfile(uid))?.displayName;
    } on Exception {
      name = null;
    }
    name ??= accountName;
    return (name == null || name.trim().isEmpty) ? 'Sin nombre' : name.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva sesión')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _description,
              maxLength: 140,
              decoration: const InputDecoration(labelText: '¿Qué vas a hacer?'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe qué vas a hacer' : null,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final c in SessionCategory.values)
                  ChoiceChip(
                    label: Text(categoryLabel(c)),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _minutes,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Minutos'),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                return (n == null || n < 1 || n > 480) ? 'Entre 1 y 480 minutos' : null;
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pública'),
              subtitle: const Text('Si no, solo la ven tus amigos'),
              value: _public,
              onChanged: (v) => setState(() => _public = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save, // desactivado mientras guarda: sin dobles envíos
              child: Text(_saving ? 'Publicando…' : 'Empezar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}