import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ten_k_hours/core/constants.dart';
import 'package:ten_k_hours/features/pursuits/data/pursuit_providers.dart';

enum _TargetMode { defaultGoal, shortTimer, longGoal }

class CreatePursuitScreen extends ConsumerStatefulWidget {
  const CreatePursuitScreen({super.key});

  @override
  ConsumerState<CreatePursuitScreen> createState() =>
      _CreatePursuitScreenState();
}

class _CreatePursuitScreenState extends ConsumerState<CreatePursuitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _longHoursCtrl = TextEditingController(
    text: '${kDefaultTargetMinutes ~/ 60}',
  );
  _TargetMode _mode = _TargetMode.defaultGoal;
  Duration _shortDuration = const Duration(minutes: 30);
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _longHoursCtrl.dispose();
    super.dispose();
  }

  int _resolveTargetMinutes() {
    switch (_mode) {
      case _TargetMode.defaultGoal:
        return kDefaultTargetMinutes;
      case _TargetMode.shortTimer:
        // Apple's picker hard-caps at 23:59:59. Floor to at least 1 minute.
        final m = _shortDuration.inMinutes;
        return m < 1 ? 1 : m;
      case _TargetMode.longGoal:
        final h = int.tryParse(_longHoursCtrl.text) ?? 0;
        return h * 60;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final targetMinutes = _resolveTargetMinutes();
    if (targetMinutes <= 0) return;
    setState(() => _submitting = true);
    try {
      final repo = ref.read(pursuitRepositoryProvider);
      final pursuit = await repo.create(
        name: _nameCtrl.text.trim(),
        accentColor: kDefaultAccentColor.toARGB32(),
        targetMinutes: targetMinutes,
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
          child: SingleChildScrollView(
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
                Text(
                  'Target',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SegmentedButton<_TargetMode>(
                  segments: const [
                    ButtonSegment(
                      value: _TargetMode.defaultGoal,
                      label: Text('10,000 h'),
                    ),
                    ButtonSegment(
                      value: _TargetMode.shortTimer,
                      label: Text('Short'),
                    ),
                    ButtonSegment(
                      value: _TargetMode.longGoal,
                      label: Text('Custom'),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
                const SizedBox(height: 16),
                _modeBody(theme),
                const SizedBox(height: 32),
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

  Widget _modeBody(ThemeData theme) {
    switch (_mode) {
      case _TargetMode.defaultGoal:
        return Text(
          'The classic 10,000-hour goal. Best for long-term mastery.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      case _TargetMode.shortTimer:
        return Column(
          children: [
            Text(
              'Pick hours, minutes, seconds. Max 23:59:59.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 216,
              child: CupertinoTimerPicker(
                initialTimerDuration: _shortDuration,
                onTimerDurationChanged: (d) =>
                    setState(() => _shortDuration = d),
              ),
            ),
          ],
        );
      case _TargetMode.longGoal:
        return TextFormField(
          controller: _longHoursCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Target hours',
            border: OutlineInputBorder(),
          ),
          validator: (v) {
            if (_mode != _TargetMode.longGoal) return null;
            final n = int.tryParse(v ?? '');
            if (n == null || n <= 0) return 'Must be a positive number';
            return null;
          },
        );
    }
  }
}
