import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ten_k_hours/core/constants.dart';
import 'package:ten_k_hours/features/pursuits/data/pursuit_providers.dart';

class CreatePursuitScreen extends ConsumerStatefulWidget {
  const CreatePursuitScreen({super.key});

  @override
  ConsumerState<CreatePursuitScreen> createState() =>
      _CreatePursuitScreenState();
}

class _CreatePursuitScreenState extends ConsumerState<CreatePursuitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController(text: '$kDefaultTargetHours');
  bool _customizeTarget = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final repo = ref.read(pursuitRepositoryProvider);
      final target = _customizeTarget
          ? int.parse(_targetCtrl.text)
          : kDefaultTargetHours;
      final pursuit = await repo.create(
        name: _nameCtrl.text.trim(),
        accentColor: kDefaultAccentColor.toARGB32(),
        targetHours: target,
      );
      if (!mounted) return;
      context.go('/pursuit/${pursuit.id}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('New pursuit')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'What are you mastering?',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: true,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    hintText: 'e.g. learning guitar',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Give it a name';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _customizeTarget,
                  onChanged: (v) => setState(() => _customizeTarget = v),
                  title: const Text('Customize target hours'),
                  subtitle: Text(
                    _customizeTarget
                        ? 'Choose any number of hours'
                        : 'Default: $kDefaultTargetHours hours',
                  ),
                ),
                if (_customizeTarget) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _targetCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Target hours',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) {
                        return 'Must be a positive number';
                      }
                      return null;
                    },
                  ),
                ],
                const Spacer(),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Start tracking'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
