import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../design_system/theme/app_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../view_models/authentication_view_model.dart';
import 'minute_clock.dart';

enum AuthLayout {
  compact(24, 88),
  notebook(40, 208);

  const AuthLayout(this.padding, this.mascotSize);
  final double padding;
  final double mascotSize;
  static AuthLayout forWidth(double width) => switch (width) {
    < AppLayout.tablet => compact,
    _ => notebook,
  };
}

class AuthenticationView extends StatefulWidget {
  const AuthenticationView({
    required this.viewModel,
    this.languageSelector,
    super.key,
  });
  final AuthenticationViewModel viewModel;
  final Widget? languageSelector;

  @override
  State<AuthenticationView> createState() => _AuthenticationViewState();
}

class _AuthenticationViewState extends State<AuthenticationView> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _currentPassword = TextEditingController();
  late AuthMode _mode;
  AuthNotice? _lastNotice;

  @override
  void initState() {
    super.initState();
    _mode = widget.viewModel.mode;
    _lastNotice = widget.viewModel.notice;
    _email.text = widget.viewModel.email;
    _password.addListener(_refreshPasswordValidation);
    _confirmPassword.addListener(_refreshPasswordValidation);
    widget.viewModel.addListener(_syncForm);
  }

  void _syncForm() {
    if (_mode != widget.viewModel.mode ||
        (widget.viewModel.notice != null &&
            _lastNotice != widget.viewModel.notice)) {
      _password.clear();
      _confirmPassword.clear();
      _currentPassword.clear();
      _mode = widget.viewModel.mode;
      if (_email.text != widget.viewModel.email) {
        _email.text = widget.viewModel.email;
      }
    }
    _lastNotice = widget.viewModel.notice;
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_syncForm);
    _name.dispose();
    _email.dispose();
    _password.removeListener(_refreshPasswordValidation);
    _confirmPassword.removeListener(_refreshPasswordValidation);
    _password.dispose();
    _confirmPassword.dispose();
    _currentPassword.dispose();
    super.dispose();
  }

  void _refreshPasswordValidation() => setState(() {});

  bool get _canSubmit =>
      widget.viewModel.canSubmitForm(_password.text, _confirmPassword.text);

  double _statusBarHeight(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    // Hiding the native bar can remove its inset on devices without a cutout.
    final double minimum =
        !kIsWeb &&
            defaultTargetPlatform == TargetPlatform.iOS &&
            media.orientation == Orientation.portrait
        ? 54
        : 32;
    return math.max(media.viewPadding.top, minimum);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.viewModel,
    builder: (BuildContext context, Widget? child) => Scaffold(
      backgroundColor: AppColors.paperWarm,
      body: Stack(
        children: [
          SafeArea(
            bottom:
                AuthLayout.forWidth(MediaQuery.sizeOf(context).width) ==
                AuthLayout.compact,
            minimum: EdgeInsets.only(
              top:
                  AuthLayout.forWidth(MediaQuery.sizeOf(context).width) ==
                      AuthLayout.compact
                  ? _statusBarHeight(context)
                  : 0,
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final AuthLayout layout = AuthLayout.forWidth(
                  constraints.maxWidth,
                );
                final bool compact = layout == AuthLayout.compact;
                if (!compact) {
                  return ColoredBox(
                    color: AppColors.paper,
                    child: SingleChildScrollView(
                      key: const ValueKey('auth-scroll'),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            key: const ValueKey('auth-notebook'),
                            children: [
                              _header(context, layout),
                              Expanded(
                                child: _NotebookAuthBody(
                                  width: constraints.maxWidth,
                                  form: _form(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                final double compactTopPadding =
                    widget.viewModel.mode == AuthMode.login &&
                        widget.viewModel.allowRememberDevice
                    ? 18
                    : 4;
                const double margin = 8;
                const double radius = 32;
                return CustomPaint(
                  painter: const _PaperDots(),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      key: const ValueKey('auth-scroll'),
                      padding: EdgeInsets.fromLTRB(margin, margin, margin, 0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                minHeight: math.max(
                                  0,
                                  constraints.maxHeight - margin - 16,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.notebook,
                                borderRadius: BorderRadius.circular(radius),
                                border: Border.all(
                                  color: AppColors.paperBorder,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(radius),
                                child: Stack(
                                  children: [
                                    Column(
                                      key: const ValueKey('auth-mobile'),
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _CompactAuthBody(
                                          availableHeight:
                                              constraints.maxHeight -
                                              margin -
                                              16,
                                          topPadding: compactTopPadding,
                                          form: _form(
                                            context,
                                            fillProviders: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (AuthLayout.forWidth(MediaQuery.sizeOf(context).width) ==
              AuthLayout.compact)
            Positioned(
              top: 0,
              left: MediaQuery.viewPaddingOf(context).left,
              right: MediaQuery.viewPaddingOf(context).right,
              child: _DeviceStatusBar(height: _statusBarHeight(context)),
            ),
        ],
      ),
    ),
  );

  Widget _header(BuildContext context, AuthLayout layout) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final String locale = Localizations.localeOf(context).languageCode == 'et'
        ? 'et_EE'
        : Localizations.localeOf(context).toString();
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.paperBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          const ExcludeSemantics(
            child: Icon(Icons.circle, color: AppColors.honey, size: 8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: MinuteClock(
              builder: (BuildContext context, DateTime now) => Text(
                '${DateFormat.yMd(locale).format(now)}  |  ${DateFormat.Hm(locale).format(now)}',
                style: AppTypography.notebookCaption.copyWith(
                  color: AppColors.honey,
                ),
              ),
            ),
          ),
          if (layout == AuthLayout.notebook &&
              MediaQuery.sizeOf(context).width >= 1000)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                strings.authNotebook,
                style: AppTypography.smallCaption,
              ),
            ),
          if (layout == AuthLayout.notebook && widget.languageSelector != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: widget.languageSelector!,
            ),
        ],
      ),
    );
  }

  String? _fieldError(String field, AppLocalizations strings) {
    final List<String>? errors = widget.viewModel.fieldErrors[field];
    if (errors != null && errors.isNotEmpty) return errors.join('\n');
    final AuthValidation? validation = widget
        .viewModel
        .validation[field == 'newPassword' ? 'password' : field];
    return switch (validation) {
      null => null,
      AuthValidation.required => strings.authRequired,
      AuthValidation.email => strings.authInvalidEmail,
      AuthValidation.nameLength => strings.authNameLength,
      AuthValidation.passwordLength => strings.authPasswordLength,
      AuthValidation.passwordPolicy => strings.authPolicy,
      AuthValidation.passwordMismatch => strings.authPasswordMismatch,
    };
  }

  Widget _field(
    BuildContext context, {
    required String field,
    required String label,
    required TextEditingController controller,
    String? hint,
    bool password = false,
    bool email = false,
    Widget? action,
    Iterable<String>? autofillHints,
    TextInputAction inputAction = TextInputAction.next,
    double bottomSpacing = 18,
    String? errorText,
  }) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.notebookCaption.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextField(
            key: ValueKey('auth-$field'),
            controller: controller,
            enabled: !widget.viewModel.busy,
            obscureText: password && !widget.viewModel.passwordVisible,
            keyboardType: email
                ? TextInputType.emailAddress
                : TextInputType.text,
            textInputAction: inputAction,
            autofillHints: autofillHints,
            autocorrect: !password && !email,
            enableSuggestions: !password && !email,
            style: AppTypography.notebookCaption.copyWith(fontSize: 16),
            onSubmitted: inputAction == TextInputAction.done
                ? (_) => _submit()
                : null,
            decoration: InputDecoration(
              hintText: hint ?? (password ? label : null),
              hintStyle: AppTypography.notebookCaption.copyWith(
                fontSize: 16,
                color: AppColors.outline,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.normal,
              ),
              errorText: errorText ?? _fieldError(field, strings),
              errorMaxLines: 5,
              fillColor: Colors.transparent,
              filled: false,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.paperBorder),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.paperBorder),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.notebookInk, width: 2),
              ),
              suffixIcon: password
                  ? IconButton(
                      tooltip: widget.viewModel.passwordVisible
                          ? strings.authHidePassword
                          : strings.authShowPassword,
                      onPressed: widget.viewModel.togglePasswordVisibility,
                      icon: Icon(
                        widget.viewModel.passwordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                    )
                  : null,
            ),
          ),
          if (action != null)
            Align(alignment: Alignment.centerRight, child: action),
        ],
      ),
    );
  }

  void _submit() {
    if (!_canSubmit) return;
    widget.viewModel.submit(
      name: _name.text,
      email: _email.text,
      password: _password.text,
      currentPassword: _currentPassword.text,
      confirmPassword: _confirmPassword.text,
    );
  }

  Widget _form(BuildContext context, {bool fillProviders = false}) {
    final bool spreadVertically =
        AuthLayout.forWidth(MediaQuery.sizeOf(context).width) ==
            AuthLayout.notebook &&
        MediaQuery.orientationOf(context) == Orientation.portrait;
    return AutofillGroup(
      child: Column(
        mainAxisSize: spreadVertically ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: spreadVertically
            ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._formHeading(context),
          ..._formFields(context),
          ..._submitButton(context),
          ..._providerSection(context, fillProviders: fillProviders),
          ..._formNavigation(context),
        ],
      ),
    );
  }

  String _submitLabel(AppLocalizations strings) =>
      switch (widget.viewModel.mode) {
        AuthMode.login => strings.authEnter,
        AuthMode.register => strings.authCreate,
        AuthMode.forgotPassword => strings.authRecover,
        AuthMode.resetPassword => strings.authReset,
        AuthMode.changePassword => strings.authChange,
      };

  List<Widget> _formHeading(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AuthenticationViewModel model = widget.viewModel;
    final bool login = model.mode == AuthMode.login;
    final bool register = model.mode == AuthMode.register;
    final String title = _submitLabel(strings);
    return [
      if (login || register) ...[
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.paperWarm,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.paperBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _tab(strings.authLogin, AuthMode.login),
                _tab(strings.authRegister, AuthMode.register),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ] else ...[
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        if (model.mode == AuthMode.forgotPassword ||
            model.mode == AuthMode.resetPassword)
          Text(
            model.mode == AuthMode.forgotPassword
                ? strings.authRecoveryHelp
                : strings.authResetHelp,
            style: AppTypography.notebookCaption,
          ),
        const SizedBox(height: 24),
      ],
      if (model.notice != null)
        _feedback(_notice(strings, model.notice!), false),
      if (model.failure != null) _feedback(_failure(strings, model), true),
    ];
  }

  List<Widget> _formFields(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AuthenticationViewModel model = widget.viewModel;
    final bool login = model.mode == AuthMode.login;
    final bool register = model.mode == AuthMode.register;
    final bool slimLogin =
        login &&
        AuthLayout.forWidth(MediaQuery.sizeOf(context).width) ==
            AuthLayout.compact;
    final bool emailMode =
        login || register || model.mode == AuthMode.forgotPassword;
    return [
      if (register)
        _field(
          context,
          field: 'name',
          label: strings.authName,
          controller: _name,
          hint: strings.authNameHint,
          autofillHints: const [AutofillHints.name],
        ),
      if (emailMode)
        _field(
          context,
          field: 'email',
          label: strings.authEmail,
          controller: _email,
          hint: strings.authEmailHint,
          email: true,
          inputAction: model.mode == AuthMode.forgotPassword
              ? TextInputAction.done
              : TextInputAction.next,
          autofillHints: const [AutofillHints.email, AutofillHints.username],
        ),
      if (model.mode == AuthMode.changePassword)
        _field(
          context,
          field: 'currentPassword',
          label: strings.authCurrentPassword,
          controller: _currentPassword,
          password: true,
          autofillHints: const [AutofillHints.password],
        ),
      if (model.mode != AuthMode.forgotPassword)
        _field(
          context,
          field:
              model.mode == AuthMode.resetPassword ||
                  model.mode == AuthMode.changePassword
              ? 'newPassword'
              : 'password',
          label: login || register
              ? strings.authPassword
              : strings.authNewPassword,
          controller: _password,
          password: true,
          bottomSpacing: slimLogin && model.allowRememberDevice ? 4 : 18,
          errorText:
              register &&
                  _password.text.isNotEmpty &&
                  !model.isValidNewPassword(_password.text)
              ? strings.authPolicy
              : null,
          inputAction: register ? TextInputAction.next : TextInputAction.done,
          autofillHints: [
            login ? AutofillHints.password : AutofillHints.newPassword,
          ],
          action: login
              ? TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.pencil,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerRight,
                  ),
                  onPressed: model.busy
                      ? null
                      : () => model.selectMode(AuthMode.forgotPassword),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.pencil),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        strings.authForgot,
                        style: AppTypography.notebookCaption,
                      ),
                    ),
                  ),
                )
              : null,
        ),
      if (register)
        _field(
          context,
          field: 'confirmPassword',
          label: strings.authConfirmPassword,
          controller: _confirmPassword,
          password: true,
          inputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          errorText:
              _confirmPassword.text.isNotEmpty &&
                  model.confirmationValidation(
                        _password.text,
                        _confirmPassword.text,
                      ) !=
                      null
              ? strings.authPasswordMismatch
              : null,
        ),
      if (model.mode == AuthMode.resetPassword ||
          model.mode == AuthMode.changePassword) ...[
        Text(strings.authPolicy, style: AppTypography.notebookCaption),
        const SizedBox(height: 18),
      ],
      if (login && model.allowRememberDevice)
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: model.rememberDevice,
          activeColor: AppColors.honey,
          checkColor: AppColors.onHoney,
          title: Text(
            strings.authRemember,
            style: AppTypography.notebookCaption,
          ),
          onChanged: model.busy
              ? null
              : (bool? value) => model.setRememberDevice(value ?? false),
        ),
    ];
  }

  List<Widget> _submitButton(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AuthenticationViewModel model = widget.viewModel;
    final String title = _submitLabel(strings);
    final bool slimSubmit =
        (model.mode == AuthMode.login || model.mode == AuthMode.register) &&
        AuthLayout.forWidth(MediaQuery.sizeOf(context).width) ==
            AuthLayout.compact;
    return [
      const SizedBox(height: 12),
      FilledButton(
        key: const ValueKey('auth-submit'),
        onPressed: _canSubmit ? _submit : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.honey,
          foregroundColor: AppColors.onHoney,
          minimumSize: Size(double.infinity, slimSubmit ? 36 : 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: slimSubmit ? 4 : 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (model.busy) ...[
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.pencil,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  model.busy ? strings.authWorking : title,
                  textAlign: TextAlign.center,
                ),
              ),
              if (!model.busy) ...[
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _providerSection(
    BuildContext context, {
    required bool fillProviders,
  }) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AuthenticationViewModel model = widget.viewModel;
    final bool login = model.mode == AuthMode.login;
    final bool register = model.mode == AuthMode.register;
    return [
      if (login || register) ...[
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.paperBorder)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                strings.authOrContinue.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTypography.smallCaption,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Divider(color: AppColors.paperBorder)),
          ],
        ),
        if (fillProviders)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _providerButtons(),
              ),
            ),
          )
        else ...[
          const SizedBox(height: 16),
          _providerButtons(),
        ],
        if (model.providerUnavailable)
          _feedback(strings.authProviderSoon, false),
      ],
    ];
  }

  List<Widget> _formNavigation(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final AuthenticationViewModel model = widget.viewModel;
    final bool login = model.mode == AuthMode.login;
    final bool register = model.mode == AuthMode.register;
    return [
      if (!(login || register)) ...[
        const SizedBox(height: 12),
        TextButton(
          onPressed: model.busy ? null : () => model.selectMode(AuthMode.login),
          child: Text(
            model.mode == AuthMode.changePassword
                ? strings.authCancel
                : strings.authBack,
          ),
        ),
      ],
      if (model.failure == AuthFailure.invalidReset)
        TextButton(
          onPressed: model.busy
              ? null
              : () => model.selectMode(AuthMode.forgotPassword),
          child: Text(strings.authRecover),
        ),
    ];
  }

  Widget _providerButtons() => Wrap(
    alignment: WrapAlignment.center,
    spacing: 12,
    runSpacing: 12,
    children: [
      _providerButton(
        'Google',
        const CustomPaint(size: Size(20, 20), painter: _GoogleIcon()),
      ),
      _providerButton('Apple', const Icon(Icons.apple, size: 22)),
    ],
  );

  Widget _providerButton(String label, Widget icon) => Tooltip(
    message: label,
    child: SizedBox(
      width: 120,
      child: OutlinedButton(
        onPressed: widget.viewModel.busy
            ? null
            : widget.viewModel.showProviderUnavailable,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.notebook,
          foregroundColor: AppColors.notebookInk,
          side: const BorderSide(color: AppColors.paperBorder),
          minimumSize: const Size.square(AppLayout.minimumTapHeight),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Semantics(
          label: label,
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 8),
                Flexible(child: Text(label, textAlign: TextAlign.center)),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _tab(String label, AuthMode mode) {
    final bool selected = widget.viewModel.mode == mode;
    return Expanded(
      child: Semantics(
        selected: selected,
        child: TextButton(
          key: ValueKey('auth-tab-${mode.name}'),
          onPressed: widget.viewModel.busy
              ? null
              : () => widget.viewModel.selectMode(mode),
          style: TextButton.styleFrom(
            backgroundColor: selected ? AppColors.notebook : Colors.transparent,
            foregroundColor: selected
                ? AppColors.notebookInk
                : AppColors.pencil,
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.notebookCaption.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _feedback(String message, bool error) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: error
              ? Theme.of(context).colorScheme.errorContainer
              : AppColors.pastelSage,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: AppTypography.notebookCaption.copyWith(
            color: error
                ? Theme.of(context).colorScheme.onErrorContainer
                : AppColors.notebookInk,
          ),
        ),
      ),
    ),
  );

  String _failure(AppLocalizations s, AuthenticationViewModel m) =>
      switch (m.failure!) {
        AuthFailure.currentPassword => s.authInvalidCurrentPassword,
        AuthFailure.forbidden => s.authForbidden,
        AuthFailure.sessionExpired => s.authSessionExpired,
        AuthFailure.credentials => s.authInvalidCredentials,
        AuthFailure.duplicateEmail => s.authDuplicateEmail,
        AuthFailure.invalidReset => s.authInvalidReset,
        AuthFailure.rateLimited => s.authRateLimit(m.cooldownSeconds),
        AuthFailure.network => s.authNetworkError,
        AuthFailure.unknown => s.authUnknownError,
        AuthFailure.uncertain => s.authUncertain,
        AuthFailure.uncertainPasswordChange => s.authUncertainChange,
        AuthFailure.storage => s.authStorageError,
      };

  String _notice(AppLocalizations s, AuthNotice n) => switch (n) {
    AuthNotice.registered => s.authRegistered,
    AuthNotice.recoveryRequested => s.authRecoverySent,
    AuthNotice.passwordReset => s.authPasswordReset,
    AuthNotice.passwordChanged => s.authPasswordChanged,
    AuthNotice.signedOut => s.authSignedOut,
    AuthNotice.localSignOut => s.authLocalSignOut,
  };
}

class _CompactAuthBody extends StatelessWidget {
  const _CompactAuthBody({
    required this.availableHeight,
    required this.topPadding,
    required this.form,
  });
  final double availableHeight;
  final double topPadding;
  final Widget form;
  @override
  Widget build(BuildContext context) {
    const AuthLayout layout = AuthLayout.compact;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.padding,
        topPadding,
        layout.padding,
        layout.padding,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: math.max(0, availableHeight - topPadding - layout.padding),
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              _WelcomePanel(layout: layout),
              const SizedBox(height: 24),
              Expanded(child: form),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotebookAuthBody extends StatelessWidget {
  const _NotebookAuthBody({required this.width, required this.form});
  final double width;
  final Widget form;
  @override
  Widget build(BuildContext context) {
    const AuthLayout layout = AuthLayout.notebook;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.notebook,
                border: Border(right: BorderSide(color: AppColors.paperBorder)),
              ),
              padding: EdgeInsets.all(layout.padding),
              child: _WelcomePanel(layout: layout),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              color: AppColors.paper,
              padding: EdgeInsets.all(width < 800 ? 24 : layout.padding)
                  .copyWith(
                    bottom:
                        (width < 800 ? 24 : layout.padding) +
                        MediaQuery.viewPaddingOf(context).bottom,
                  ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppLayout.formWidth,
                  ),
                  child: form,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceStatusBar extends StatelessWidget {
  const _DeviceStatusBar({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: MinuteClock(
                builder: (BuildContext context, DateTime now) => Text(
                  MaterialLocalizations.of(context).formatTimeOfDay(
                    TimeOfDay.fromDateTime(now),
                    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(
                      context,
                    ),
                  ),
                  style: AppTypography.notebookCaption.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    height: 1.5,
                    color: AppColors.honey,
                  ),
                ),
              ),
            ),
          ),
          // Keep the center clear for the camera cutout / Dynamic Island.
          SizedBox(
            width: math.min(164, MediaQuery.sizeOf(context).width * 0.42),
          ),
          // Decorative indicators for the visual preview, not device readings.
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: ExcludeSemantics(
                child: IconTheme(
                  data: const IconThemeData(color: AppColors.honey, size: 18),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_rounded),
                      SizedBox(width: 8),
                      RotatedBox(
                        quarterTurns: 1,
                        child: Icon(Icons.battery_full_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.layout});
  final AuthLayout layout;
  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final bool spreadVertically =
        layout == AuthLayout.notebook &&
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final TextStyle brandStyle = TextStyle(
      fontFamily: layout == AuthLayout.compact
          ? AppTypography.typewriterFamily
          : AppTypography.family,
      fontSize: layout.mascotSize * .55,
      fontWeight: FontWeight.w800,
      letterSpacing: -2,
      color: AppColors.honey,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: spreadVertically
          ? MainAxisAlignment.spaceEvenly
          : MainAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          height: layout.mascotSize + 24,
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Semantics(
                      header: true,
                      label: 'BeeHome',
                      excludeSemantics: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Bee', style: brandStyle),
                          _FloatingBee(size: layout.mascotSize),
                          Text('Home', style: brandStyle),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!spreadVertically) const SizedBox(height: 12),
        Text(
          strings.authTagline,
          textAlign: TextAlign.center,
          style: AppTypography.notebookCaption.copyWith(
            color: AppColors.pencil,
          ),
        ),
        if (layout == AuthLayout.notebook) ...[
          if (!spreadVertically) const SizedBox(height: 56),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(color: AppColors.paperBorder),
              const SizedBox(height: 12),
              Text(
                '🍯 ${strings.authDayTip}',
                style: AppTypography.notebookCaption.copyWith(
                  color: AppColors.pencil,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _FloatingBee extends StatefulWidget {
  const _FloatingBee({required this.size});
  final double size;
  @override
  State<_FloatingBee> createState() => _FloatingBeeState();
}

class _FloatingBeeState extends State<_FloatingBee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.stop();
      _animation.value = 0;
    } else {
      _animation.repeat();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.size,
    height: widget.size,
    child: AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) => Transform.translate(
        offset: Offset(
          0,
          -widget.size * .10 -
              widget.size * .035 * math.sin(_animation.value * math.pi * 2),
        ),
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset('assets/mascote.png', excludeFromSemantics: true),
      ),
    ),
  );
}

class _PaperDots extends CustomPainter {
  const _PaperDots();
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = AppColors.paperDot;
    for (double x = 12; x < size.width; x += 24) {
      for (double y = 12; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), .75, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PaperDots oldDelegate) => false;
}

class _GoogleIcon extends CustomPainter {
  const _GoogleIcon();

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.shortestSide / 20;
    canvas.save();
    canvas.scale(unit);
    const Rect ring = Rect.fromLTWH(2, 2, 16, 16);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    for (final (Color, double, double) segment in const [
      (Color(0xFF4285F4), 0.0, 45.0),
      (Color(0xFF34A853), 45.0, 100.0),
      (Color(0xFFFBBC05), 145.0, 65.0),
      (Color(0xFFEA4335), 210.0, 100.0),
    ]) {
      paint.color = segment.$1;
      canvas.drawArc(
        ring,
        segment.$2 * math.pi / 180,
        segment.$3 * math.pi / 180,
        false,
        paint,
      );
    }
    paint.color = const Color(0xFF4285F4);
    canvas.drawLine(const Offset(10, 10), const Offset(20, 10), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GoogleIcon oldDelegate) => false;
}
