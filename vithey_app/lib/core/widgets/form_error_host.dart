import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Hosts per-form error visibility for [VitheyField] / [CustomTextField].
///
/// Flow:
/// - Submit: [submit] unfocuses first, then shows errors once
/// - Any other interaction (field focus / tap outside): [clearAll] → idle
class FormErrorHost extends StatefulWidget {
  const FormErrorHost({
    super.key,
    required this.formKey,
    required this.child,
  });

  final GlobalKey<FormState> formKey;
  final Widget child;

  static final Set<_FormErrorHostState> _hosts = {};

  /// Clears validation errors on every mounted [FormErrorHost].
  static void clearAll() {
    for (final host in _hosts.toList()) {
      host.clearErrors();
    }
  }

  /// Turns on error display for the host that owns [formKey] (sync).
  static void activateFor(GlobalKey<FormState> formKey) {
    for (final host in _hosts) {
      if (identical(host.widget.formKey, formKey)) {
        host.activateErrors();
        return;
      }
    }
  }

  /// Unfocus any focused field, then show errors and validate.
  ///
  /// Use from Sign In / Next / Sign Up submit so a pre-focused field does not
  /// keep primary focus chrome over the red error state.
  static Future<bool> submit(GlobalKey<FormState> formKey) async {
    FocusManager.instance.primaryFocus?.unfocus();
    // Let focus/chrome settle before painting Required errors.
    await SchedulerBinding.instance.endOfFrame;
    await Future<void>.delayed(Duration.zero);
    activateFor(formKey);
    return formKey.currentState?.validate() ?? false;
  }

  @override
  State<FormErrorHost> createState() => _FormErrorHostState();
}

class _FormErrorHostState extends State<FormErrorHost> {
  /// Sync flag — readable in the same frame as [activateErrors] + validate.
  final ValueNotifier<bool> showErrors = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    FormErrorHost._hosts.add(this);
  }

  @override
  void dispose() {
    FormErrorHost._hosts.remove(this);
    showErrors.dispose();
    super.dispose();
  }

  void activateErrors() {
    showErrors.value = true;
  }

  void clearErrors() {
    if (!showErrors.value) return;
    showErrors.value = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.formKey.currentState?.validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _FieldErrorScope(
      showErrors: showErrors,
      activateErrors: activateErrors,
      clearErrors: clearErrors,
      child: widget.child,
    );
  }
}

class _FieldErrorScope extends InheritedWidget {
  const _FieldErrorScope({
    required this.showErrors,
    required this.activateErrors,
    required this.clearErrors,
    required super.child,
  });

  final ValueNotifier<bool> showErrors;
  final VoidCallback activateErrors;
  final VoidCallback clearErrors;

  static _FieldErrorScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FieldErrorScope>();
  }

  @override
  bool updateShouldNotify(_FieldErrorScope oldWidget) {
    return showErrors != oldWidget.showErrors;
  }
}

/// Public helpers for buttons / fields.
abstract final class FieldErrors {
  static void activate(BuildContext context) {
    _FieldErrorScope.maybeOf(context)?.activateErrors();
  }

  static void clear(BuildContext context) {
    _FieldErrorScope.maybeOf(context)?.clearErrors();
  }

  /// Whether validators should surface errors (sync-safe).
  static bool show(BuildContext context) {
    final scope = _FieldErrorScope.maybeOf(context);
    if (scope == null) return true;
    return scope.showErrors.value;
  }
}
