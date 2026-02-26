import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// About page with software details and license access.
class AboutScreen extends StatelessWidget {
  /// Creates the about page.
  const AboutScreen({super.key});

  static final Uri _repoUrl = Uri.parse('https://github.com/rriet/simplelog');

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'About'),
              Tab(text: 'Licenses'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _AboutTab(openRepository: _openRepository),
                const LicensePage(
                  applicationName: 'SimpleLog',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openRepository() async {
    if (await canLaunchUrl(_repoUrl)) {
      await launchUrl(_repoUrl, mode: LaunchMode.externalApplication);
      return;
    }
    debugPrint('Could not launch $_repoUrl');
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.openRepository});

  final Future<void> Function() openRepository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.flight_takeoff_rounded,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SimpleLog',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilot Logbook • Made by a Pilot, for Pilots',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Card(
              elevation: isDark ? 2 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why SimpleLog',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'SimpleLog was born in the cockpit: built by a real '
                      'airline pilot who got fed up with scribbling on paper '
                      "like it's 1976.\n\n"
                      'This app replaces my previous Java '
                      'logbook software, which I developed and used for '
                      'many years as an airline pilot. '
                      'The rewrite brings mobile support, modern UI, and '
                      'easier data portability — while preserving the core '
                      'focus on quick, accurate entries in real operations.\n\n'
                      'Just punch in takeoff, landing, airports and times → '
                      'smash Calculate → watch how fast totals and breakdowns '
                      'gets calculated automatically → save and done.\n\n'
                      'No nonsense, no subscriptions, no server drama. Your '
                      'flights stay yours, stored locally, synced on local '
                      'network.\n\n'
                      'Open source. Free forever. Fly. Log. Repeat.\n'
                      'If it saves you time, a coffee keeps the lights on. ☕✈️',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
              elevation: isDark ? 4 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: openRepository,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.code_rounded,
                            size: 36,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Open Source on GitHub',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Documentation • Tutorials • Sync setup • '
                                  'Desktop builds • Bug tracker • Future '
                                  'features',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tap here to visit the project page →',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'github.com/rriet/simplelog',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 15,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: isDark ? 2 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          color: Colors.redAccent,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Support SimpleLog',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'SimpleLog will always remain free and open source.\n\n'
                      'Ongoing costs include Apple & Google developer '
                      'accounts, '
                      'test devices, and countless hours improving the app '
                      'based on real pilot feedback.\n\n'
                      'If SimpleLog saves you time in the cockpit or makes '
                      'your logbook life easier — any support is deeply '
                      'appreciated.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      '→ The GitHub page has full documentation, tutorials, '
                      'sync guides, desktop builds, and ways to support '
                      'the project.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  Text(
                    'Flutter • Riverpod • Drift',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'GNU GPLv3 License',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
