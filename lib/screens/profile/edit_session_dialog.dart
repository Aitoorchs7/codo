import 'package:codo/models/live_session.dart';
import 'package:flutter/material.dart';

class EditSessionDialog extends StatefulWidget {
  const EditSessionDialog({super.key, required this.session});
  final LiveSession session;

  @override
  State<EditSessionDialog> createState() => _EditSessionDialogState();
}

class _EditSessionDialogState extends State<EditSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _description = TextEditingController(text: widget.session.description);
  late final _minutes = TextEditingController(text: '${widget.session.durationMinutes}');

  @override
  void dispose() {
    _description.dispose();
    _minutes.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    // Cierra el diálogo devolviendo los datos nuevos
    Navigator.pop(context, (
    description: _description.text.trim(),
    minutes: int.parse(_minutes.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar sesión'),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(
            controller: _description,
            maxLength: 140,
            decoration: const InputDecoration(labelText: 'Descripción'),
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Escribe qué estás haciendo' : null,
          ),
          TextFormField(
            controller: _minutes,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Duración (minutos)'),
            validator: (v) {
              final n = int.tryParse(v ?? '');
              if (n == null || n <= 0 || n > 480) return 'Entre 1 y 480 minutos';
              return null;
            },
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}