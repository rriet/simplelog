import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/core/presentation/widgets/inputs/hour_input_field.dart';
import 'package:simplelog/core/presentation/widgets/inputs/number_input_field.dart';

/// Shared compact row for IFR factoring controls.
///
/// Display order matches calculation order:
/// Minus, IFR %, Minimum.
class IfrFactoringFieldsRow extends StatelessWidget {
  /// Creates a compact IFR controls row.
  const IfrFactoringFieldsRow({
    required this.subtractController,
    required this.percentController,
    required this.minimumController,
    super.key,
  });

  /// Controller for the fixed minutes deducted before percentage.
  final TextEditingController subtractController;

  /// Controller for the IFR percentage.
  final TextEditingController percentController;

  /// Controller for the minimum IFR minutes.
  final TextEditingController minimumController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final eachWidth = (constraints.maxWidth - (spacing * 2)) / 3;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Wrap(
            spacing: spacing,
            runSpacing: 8,
            children: [
              SizedBox(
                width: eachWidth,
                child: HourInputField(
                  controller: subtractController,
                  label: l10n.settingsCalculationRulesMinusLabel,
                ),
              ),
              SizedBox(
                width: eachWidth,
                child: NumberInputField(
                  controller: percentController,
                  label: l10n.simplelogIfrPercentLabel,
                ),
              ),
              SizedBox(
                width: eachWidth,
                child: HourInputField(
                  controller: minimumController,
                  label: l10n.settingsCalculationRulesMinimumLabel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
