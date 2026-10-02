import 'package:flutter/material.dart';

import '../../design_system/components/foundation_panel.dart';
import '../../design_system/theme/app_theme.dart';
import '../../design_system/theme/app_tokens.dart';
import '../../l10n/generated/app_localizations.dart';
import '../view_models/app_view_model.dart';
import 'splash_view.dart';

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
                  onPressed: viewModel.initialize,
                  child: Text(strings.retry),
                ),
              );
            case AppViewState.signedIn:
              panel = FoundationPanel(
                title: strings.workspace,
                message: strings.signedInMessage,
                action: FilledButton(
                  onPressed: viewModel.signOut,
                  child: Text(strings.signOut),
                ),
              );
            case AppViewState.signedOut:
              panel = FoundationPanel(
                title: strings.welcome,
                message: strings.signedOutMessage,
              );
          }
          return FoundationLayout(panel: panel);
        },
      ),
    ),
  );
}

class FoundationLayout extends StatelessWidget {
  const FoundationLayout({required this.panel, super.key});
  final Widget panel;

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
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayout.contentWidth,
                ),
                child: content,
              ),
            ),
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
