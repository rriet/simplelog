import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/state/aircraft_state.dart';
import 'package:simplelog/state/providers/app_version_provider.dart';

/// Main navigation drawer listing all top-level app screens.
class AppDrawer extends ConsumerWidget {
  /// Creates an app drawer with the current [selected] screen.
  const AppDrawer({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  static const List<AppScreen> _screens = [
    AppScreen.logbook,
    AppScreen.aircraft,
    AppScreen.aircraftTypes,
    AppScreen.airports,
    AppScreen.crew,
    AppScreen.dashboard,
    AppScreen.settings,
    AppScreen.about,
  ];

  /// Currently selected screen.
  final AppScreen selected;

  /// Called when the user taps a destination.
  final ValueChanged<AppScreen> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final menuBackground = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest;
    final versionAsync = ref.watch(appVersionLabelProvider);

    return Drawer(
      backgroundColor: menuBackground,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final screen in _screens)
                    _DrawerItem(
                      label: _screenLabel(l10n, screen),
                      icon: _screenIcon(screen),
                      selected: selected == screen,
                      onTap: () => onSelected(screen),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: versionAsync.when(
                data: (value) {
                  if (value.trim().isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    l10n.menuVersionLabel(value),
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selected,
      onTap: onTap,
    );
  }
}

String _screenLabel(AppLocalizations l10n, AppScreen screen) {
  return switch (screen) {
    AppScreen.dashboard => 'Dashboard',
    AppScreen.logbook => l10n.screenLogbook,
    AppScreen.aircraft => l10n.screenAircraft,
    AppScreen.aircraftTypes => l10n.screenAircraftTypes,
    AppScreen.airports => l10n.screenAirports,
    AppScreen.crew => l10n.screenCrew,
    AppScreen.database => l10n.screenDatabase,
    AppScreen.settings => l10n.screenSettings,
    AppScreen.about => 'About',
  };
}

IconData _screenIcon(AppScreen screen) {
  return switch (screen) {
    AppScreen.dashboard => Icons.dashboard_outlined,
    AppScreen.logbook => Icons.book_outlined,
    AppScreen.aircraft => Icons.airplanemode_active_outlined,
    AppScreen.aircraftTypes => Icons.category_outlined,
    AppScreen.airports => Icons.location_on_outlined,
    AppScreen.crew => Icons.people_outline,
    AppScreen.database => Icons.storage_outlined,
    AppScreen.settings => Icons.settings_outlined,
    AppScreen.about => Icons.info_outline,
  };
}
