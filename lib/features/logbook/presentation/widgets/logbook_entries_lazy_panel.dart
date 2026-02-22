import 'package:flutter/material.dart';
import 'package:simplelog/core/l10n/app_localizations.dart';
import 'package:simplelog/data/models/logbook_entry.dart';
import 'package:simplelog/features/logbook/presentation/widgets/logbook_entries_year_list.dart';
import 'package:simplelog/presentation/shared/widgets/logbook_summary_panel.dart';

typedef LogbookEntriesPageLoader =
    Future<List<LogbookEntry>> Function(int limit, int offset);

class LogbookEntriesLazyPanel extends StatefulWidget {
  const LogbookEntriesLazyPanel({
    super.key,
    required this.pageLoader,
    required this.onEntryTap,
    this.pageSize = 120,
  });

  final LogbookEntriesPageLoader pageLoader;
  final ValueChanged<LogbookEntry> onEntryTap;
  final int pageSize;

  @override
  State<LogbookEntriesLazyPanel> createState() => _LogbookEntriesLazyPanelState();
}

class _LogbookEntriesLazyPanelState extends State<LogbookEntriesLazyPanel> {
  final List<LogbookEntry> _entries = <LogbookEntry>[];
  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (_loadingMore || !_hasMore) return;
    setState(() {
      _loadingMore = true;
      _error = null;
    });

    try {
      final page = await widget.pageLoader(widget.pageSize + 1, _entries.length);
      if (!mounted) return;
      final hasMore = page.length > widget.pageSize;
      final append = hasMore ? page.take(widget.pageSize).toList() : page;
      setState(() {
        _entries.addAll(append);
        _hasMore = hasMore;
        _initialLoading = false;
        _loadingMore = false;
      });
    } catch (error) {
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
      _loadNextPage();
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
          LogbookSummaryPanel(entries: _entries),
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

