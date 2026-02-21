import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';

import 'package:simplelog/state/aircraft_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _screens = [
    AppScreen.logbook,
    AppScreen.aircraft,
    AppScreen.aircraftTypes,
    AppScreen.airports,
    AppScreen.crew,
    AppScreen.dashboard,
    AppScreen.settings,
  ];

  final AppScreen selected;
  final ValueChanged<AppScreen> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              title: Text(
                l10n.homeTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
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
  };
}
