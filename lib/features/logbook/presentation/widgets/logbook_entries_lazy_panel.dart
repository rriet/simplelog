import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/data/models/logbook_flight_summary.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_year_list.dart';
import 'package:simplelog/presentation/shared/widgets/logbook_summary_panel.dart';

/// Fetches one page of logbook entries.
typedef LogbookEntriesPageLoader =
    Future<List<LogbookEntry>> Function(int limit, int offset);
/// Loads summary totals for the current data set.
typedef LogbookFlightSummaryLoader = Future<LogbookFlightSummary> Function();

/// Lazy-loading logbook list panel with summary header.
class LogbookEntriesLazyPanel extends StatefulWidget {
  /// Creates the lazy panel.
  const LogbookEntriesLazyPanel({
    required this.pageLoader,
    required this.summaryLoader,
    required this.onEntryTap,
    super.key,
    this.pageSize = 120,
  });

  /// Callback used to load paged entries.
  final LogbookEntriesPageLoader pageLoader;
  /// Callback used to load summary totals.
  final LogbookFlightSummaryLoader summaryLoader;
  /// Called when user taps an entry.
  final ValueChanged<LogbookEntry> onEntryTap;
  /// Page size used for incremental loads.
  final int pageSize;

  @override
  State<LogbookEntriesLazyPanel> createState() =>
      _LogbookEntriesLazyPanelState();
}

class _LogbookEntriesLazyPanelState extends State<LogbookEntriesLazyPanel> {
  final List<LogbookEntry> _entries = <LogbookEntry>[];
  LogbookFlightSummary _summary = const LogbookFlightSummary.empty();
  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _summaryLoading = true;
  bool _hasMore = true;
  Object? _error;
  Object? _summaryError;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSummary());
    unawaited(_loadNextPage());
  }

  Future<void> _loadSummary() async {
    setState(() {
      _summaryLoading = true;
      _summaryError = null;
    });
    try {
      final summary = await widget.summaryLoader();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _summaryLoading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _summaryError = error;
        _summaryLoading = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (_loadingMore || !_hasMore) return;
    setState(() {
      _loadingMore = true;
      _error = null;
    });

    try {
      final page = await widget.pageLoader(
        widget.pageSize + 1,
        _entries.length,
      );
      if (!mounted) return;
      final hasMore = page.length > widget.pageSize;
      final append = hasMore ? page.take(widget.pageSize).toList() : page;
      setState(() {
        _entries.addAll(append);
        _hasMore = hasMore;
        _initialLoading = false;
        _loadingMore = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _initialLoading = false;
        _loadingMore = false;
      });
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (!_hasMore || _loadingMore) return false;
    if (notification.metrics.extentAfter < 500) {
      unawaited(_loadNextPage());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_initialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _entries.isEmpty) {
      return Center(child: Text(l10n.emptyResults));
    }
    if (_entries.isEmpty) {
      return Center(child: Text(l10n.emptyResults));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: Column(
        children: [
          if (_summaryLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_summaryError == null)
            LogbookSummaryPanel(summary: _summary),
          const SizedBox(height: 8),
          Expanded(
            child: LogbookEntriesYearList(
              entries: _entries,
              onEntryTap: widget.onEntryTap,
            ),
          ),
          if (_loadingMore)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}
