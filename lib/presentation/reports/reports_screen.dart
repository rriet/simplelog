import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Text(l10n.screenReports),
    );
  }
}
