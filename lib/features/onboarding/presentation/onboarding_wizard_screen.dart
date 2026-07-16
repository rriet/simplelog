import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/presentation/widgets/dialogs/info_help_button.dart';
import 'package:simplelog/features/settings/presentation/widgets/duty_rules_settings_card.dart';
import 'package:simplelog/features/settings/presentation/widgets/flight_factoring_settings_card.dart';
import 'package:simplelog/features/settings/presentation/widgets/pilot_profile_settings_card.dart';
import 'package:simplelog/features/settings/presentation/widgets/simulator_default_position_selector.dart';
import 'package:simplelog/features/settings/presentation/widgets/time_fields_settings_tab.dart';
import 'package:simplelog/state/providers/onboarding_provider.dart';

/// First-run onboarding wizard for initial profile and settings setup.
class OnboardingWizardScreen extends ConsumerStatefulWidget {
  /// Creates the onboarding wizard screen.
  const OnboardingWizardScreen({super.key});

  @override
  ConsumerState<OnboardingWizardScreen> createState() =>
      _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState
    extends ConsumerState<OnboardingWizardScreen> {
  static const _lastStepIndex = 2;

  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    unawaited(
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      ),
    );
  }

  void _goNext() {
    if (_currentStep >= _lastStepIndex) return;
    _goToStep(_currentStep + 1);
  }

  void _goBack() {
    if (_currentStep <= 0) return;
    _goToStep(_currentStep - 1);
  }

  Future<void> _complete() async {
    await ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
  }

  void _dismissKeyboard() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onboardingState = ref.watch(onboardingCompletedProvider);
    final isSaving = onboardingState.isLoading;

    final titles = <String>[
      l10n.onboardingWelcomeTitle,
      l10n.onboardingPilotProfileTitle,
      l10n.onboardingFieldsTitle,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentStep]),
        actions: [
          if (_currentStep == 0)
            TextButton(
              onPressed: isSaving ? null : _complete,
              child: Text(l10n.onboardingSkipAction),
            ),
          if (_currentStep > 0)
            TextButton(
              onPressed: isSaving ? null : _goBack,
              child: Text(l10n.onboardingBackAction),
            ),
          TextButton(
            onPressed: isSaving
                ? null
                : (_currentStep == _lastStepIndex ? _complete : _goNext),
            child: Text(
              _currentStep == _lastStepIndex
                  ? l10n.onboardingFinishAction
                  : l10n.onboardingNextAction,
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _dismissKeyboard,
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            const SizedBox(height: 8),
            _StepDots(currentStep: _currentStep, stepCount: titles.length),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentStep = value;
                  });
                },
                children: [
                  _WelcomeStep(
                    title: l10n.onboardingWelcomeTitle,
                    description: l10n.onboardingWelcomeBody,
                  ),
                  const _PilotProfileAndRulesStep(),
                  _FieldsStep(
                    title: l10n.onboardingFieldsTitle,
                    description: l10n.onboardingFieldsBody,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.currentStep, required this.stepCount});

  final int currentStep;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(stepCount, (index) {
        final isActive = index == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flight_takeoff,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(title, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PilotProfileAndRulesStep extends StatelessWidget {
  const _PilotProfileAndRulesStep();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        _OnboardingCrewFunctionCard(
          title: AppLocalizations.of(context)!.settingsDefaultCrewFunctionTitle,
          helpTitle: AppLocalizations.of(
            context,
          )!.settingsDefaultCrewFunctionHelpTitle,
          helpMessage: AppLocalizations.of(
            context,
          )!.settingsDefaultCrewFunctionHelpBody,
        ),
        const SizedBox(height: 12),
        const PilotProfileSettingsCard(),
        const SizedBox(height: 12),
        const FlightFactoringSettingsCard(),
        const SizedBox(height: 12),
        const DutyRulesSettingsCard(),
      ],
    );
  }
}

class _FieldsStep extends StatelessWidget {
  const _FieldsStep({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _StepHeader(title: title, description: description),
        ),
        const SizedBox(height: 8),
        const Expanded(child: TimeFieldsSettingsTab()),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(description, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _OnboardingCrewFunctionCard extends StatelessWidget {
  const _OnboardingCrewFunctionCard({
    required this.title,
    required this.helpTitle,
    required this.helpMessage,
  });

  final String title;
  final String helpTitle;
  final String helpMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                InfoHelpButton(
                  title: helpTitle,
                  message: helpMessage,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const SimulatorDefaultPositionSelector(labelText: null),
          ],
        ),
      ),
    );
  }
}
