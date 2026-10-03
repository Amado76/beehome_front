import 'package:flutter/material.dart';

import '../../design_system/components/foundation_panel.dart';
import '../../design_system/theme/app_theme.dart';
import '../../design_system/theme/app_tokens.dart';
import '../../l10n/generated/app_localizations.dart';
import '../view_models/app_view_model.dart';
import 'splash_view.dart';
import '../../features/authentication/views/authentication_view.dart';
import '../../features/authentication/view_models/authentication_view_model.dart';

class BeeHomeApp extends StatelessWidget {
  const BeeHomeApp({
    required this.viewModel,
    this.splashBackgroundImage,
    super.key,
  });
  final AppViewModel viewModel;
  final ImageProvider<Object>? splashBackgroundImage;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (BuildContext context, Widget? child) => MaterialApp(
      title: 'BeeHome',
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: viewModel.locale,
      supportedLocales: AppViewModel.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (BuildContext context) {
          final AppLocalizations strings = AppLocalizations.of(context)!;
          final Widget panel;
          switch (viewModel.state) {
            case AppViewState.loading:
              return SplashView(
                viewModel: viewModel,
                backgroundImage: splashBackgroundImage,
              );
            case AppViewState.failure:
              panel = FoundationPanel(
                title: strings.sessionError,
                message: strings.sessionErrorMessage,
                action: FilledButton(
                  onPressed: viewModel.localeSaving
                      ? null
                      : viewModel.initialize,
                  child: Text(strings.retry),
                ),
              );
            case AppViewState.signedIn:
              if (viewModel.authentication.mode == AuthMode.changePassword) {
                return AuthenticationView(
                  viewModel: viewModel.authentication,
                  languageSelector: _LanguageSelector(viewModel: viewModel),
                );
              }
              panel = FoundationPanel(
                title: strings.workspace,
                message: strings.signedInMessage,
                action: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: viewModel.authentication.busy
                          ? null
                          : () => viewModel.authentication.selectMode(
                              AuthMode.changePassword,
                            ),
                      child: Text(strings.authChange),
                    ),
                    FilledButton(
                      onPressed: viewModel.authentication.busy
                          ? null
                          : viewModel.signOut,
                      child: Text(strings.signOut),
                    ),
                  ],
                ),
              );
            case AppViewState.signedOut:
              return AuthenticationView(
                viewModel: viewModel.authentication,
                languageSelector: _LanguageSelector(viewModel: viewModel),
              );
          }
          return FoundationLayout(
            panel: panel,
            languageSelector: _LanguageSelector(viewModel: viewModel),
          );
        },
      ),
    ),
  );
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.viewModel});

  final AppViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context)!;
    final List<(String, String, String)> languages = [
      ('', '🌐', strings.deviceLanguage),
      ('pt-BR', '🇧🇷', strings.languagePortuguese),
      ('en', '🇬🇧', strings.languageEnglish),
      ('es', '🇪🇸', strings.languageSpanish),
      ('et', '🇪🇪', strings.languageEstonian),
    ];
    final (String, String, String) current = languages.firstWhere(
      ((String, String, String) language) =>
          language.$1 == viewModel.locale.toLanguageTag(),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        PopupMenuButton<String>(
          key: const ValueKey('language-selector'),
          tooltip: '${strings.language}: ${current.$3}',
          enabled: !viewModel.localeSaving,
          icon: ExcludeSemantics(child: Text(current.$2)),
          onSelected: (String tag) => viewModel.selectLocale(
            tag.isEmpty
                ? null
                : AppViewModel.supportedLocales.firstWhere(
                    (Locale locale) => locale.toLanguageTag() == tag,
                  ),
          ),
          itemBuilder: (BuildContext context) => [
            for (final (String, String, String) language in languages)
              CheckedPopupMenuItem<String>(
                value: language.$1,
                checked:
                    language.$1 ==
                    (viewModel.localeOverride?.toLanguageTag() ?? ''),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(child: Text(language.$2)),
                    const SizedBox(width: AppSpacing.small),
                    Flexible(child: Text(language.$3)),
                  ],
                ),
              ),
          ],
        ),
        if (viewModel.localeSaving) ...[
          const SizedBox(height: AppSpacing.small),
          const SizedBox(width: 48, child: LinearProgressIndicator()),
        ],
        if (viewModel.localeSaveFailed) ...[
          const SizedBox(height: AppSpacing.small),
          Semantics(
            liveRegion: true,
            child: Text(
              strings.languageSaveError,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class FoundationLayout extends StatelessWidget {
  const FoundationLayout({
    required this.panel,
    this.languageSelector,
    super.key,
  });
  final Widget panel;
  final Widget? languageSelector;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final AppLocalizations strings = AppLocalizations.of(context)!;
          final Widget brand = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BeeHome', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.medium),
              Text(
                strings.tagline,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          );
          final Widget content;
          // Mobile stacks the brand and panel; tablet and desktop use two columns.
          if (constraints.maxWidth < AppLayout.tablet) {
            content = Column(
              key: const ValueKey('mobile-shell'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                brand,
                const SizedBox(height: AppSpacing.large),
                panel,
              ],
            );
          } else {
            content = Row(
              key: ValueKey(
                constraints.maxWidth < AppLayout.desktop
                    ? 'tablet-shell'
                    : 'desktop-shell',
              ),
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: brand),
                const SizedBox(width: AppSpacing.extraLarge),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppLayout.formWidth,
                    ),
                    child: panel,
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              if (constraints.maxWidth >= AppLayout.tablet &&
                  languageSelector != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.large,
                    vertical: AppSpacing.small,
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppLayout.formWidth,
                      ),
                      child: languageSelector!,
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppLayout.contentWidth,
                      ),
                      child: content,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class ConfigurationFailureApp extends StatelessWidget {
  const ConfigurationFailureApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'BeeHome',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    supportedLocales: AppViewModel.supportedLocales,
    localeListResolutionCallback:
        (List<Locale>? locales, Iterable<Locale> supported) =>
            AppViewModel.resolveLocale(locales),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Builder(
      builder: (BuildContext context) {
        final AppLocalizations strings = AppLocalizations.of(context)!;
        return FoundationLayout(
          panel: FoundationPanel(
            title: strings.configurationError,
            message: strings.configurationErrorMessage,
          ),
        );
      },
    ),
  );
}
