import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:simplelog/core/presentation/widgets/navigation/collapsible_scaffold.dart';
import 'package:simplelog/core/presentation/widgets/navigation/large_scaffold.dart';
import 'package:simplelog/features/onboarding/presentation/onboarding_wizard_screen.dart';
import 'package:simplelog/state/providers/initial_data_provider.dart';
import 'package:simplelog/state/providers/onboarding_provider.dart';

/// Chooses between compact and large layouts for the main home screen.
class MyHomePage extends ConsumerWidget {
  /// Creates the responsive home page.
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialData = ref.watch(initialDataProvider);
    if (initialData.isLoading) {
      return const _HomeLoadingIndicator();
    }

    if (initialData.hasError) {
      return Scaffold(
        body: Center(
          child: Text(
            initialData.error.toString(),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final onboarding = ref.watch(onboardingCompletedProvider);
    if (onboarding.isLoading) {
      return const _HomeLoadingIndicator();
    }

    if (onboarding.asData?.value != true) {
      return const OnboardingWizardScreen();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 980;

        if (isCompact) {
          return const CollapsibleScaffold();
        }

        return const LargeScaffold();
      },
    );
  }
}

class _HomeLoadingIndicator extends StatelessWidget {
  const _HomeLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
