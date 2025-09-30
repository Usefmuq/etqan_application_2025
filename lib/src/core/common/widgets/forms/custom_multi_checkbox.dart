import 'dart:async';
import 'package:flutter/material.dart';

typedef ItemLabel<T> = String Function(T item);
typedef ItemId<T> = String Function(T item);

class CustomMultiCheckbox<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;

  /// How to show a label for each item (EN/AR logic is up to you).
  final ItemLabel<T> itemLabel;

  /// A stable ID per item (used for selection equality).
  final ItemId<T> itemId;

  /// Called whenever selection changes.
  final ValueChanged<List<T>>? onChanged;

  /// Page size for the list
  final int pageSize;

  /// Optional placeholder text for the search bar
  final String searchHint;

  /// Optional title
  final String? title;

  /// Sticky header actions visible? (select all / clear)
  final bool showHeaderActions;

  /// Optional trailing builder (e.g., secondary text)
  final Widget Function(T item)? trailingBuilder;

  const CustomMultiCheckbox({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    required this.itemId,
    this.onChanged,
    this.pageSize = 10,
    this.searchHint = 'Search…',
    this.title,
    this.showHeaderActions = true,
    this.trailingBuilder,
  });

  @override
  State<CustomMultiCheckbox<T>> createState() => _CustomMultiCheckboxState<T>();
}

class _CustomMultiCheckboxState<T> extends State<CustomMultiCheckbox<T>> {
  late List<T> _selected;
  String _query = '';
  int _page = 0;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.selectedItems);
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant CustomMultiCheckbox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // keep selection in sync if parent updates it externally
    if (oldWidget.selectedItems != widget.selectedItems) {
      _selected = List<T>.from(widget.selectedItems);
    }
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      setState(() {
        _query = _searchCtrl.text.trim();
        _page = 0; // reset to first page
      });
    });
  }

  bool _isSelected(T item) {
    final id = widget.itemId(item);
    return _selected.any((e) => widget.itemId(e) == id);
  }

  void _toggle(T item) {
    final id = widget.itemId(item);
    setState(() {
      final idx = _selected.indexWhere((e) => widget.itemId(e) == id);
      if (idx >= 0) {
        _selected.removeAt(idx);
      } else {
        _selected.add(item);
      }
    });
    widget.onChanged?.call(List<T>.from(_selected));
  }

  void _selectAllOnPage(List<T> pageItems) {
    setState(() {
      for (final it in pageItems) {
        if (!_isSelected(it)) _selected.add(it);
      }
    });
    widget.onChanged?.call(List<T>.from(_selected));
  }

  void _clearSelection() {
    setState(() => _selected.clear());
    widget.onChanged?.call(const []);
  }

  List<T> get _filtered {
    if (_query.isEmpty) return widget.items;
    final q = _query.toLowerCase();
    return widget.items.where((it) {
      final label = widget.itemLabel(it).toLowerCase();
      return label.contains(q);
    }).toList();
  }

  int get _pageCount {
    final total = _filtered.length;
    return total == 0 ? 1 : (total / widget.pageSize).ceil();
  }

  List<T> get _pageItems {
    final start = _page * widget.pageSize;
    final end = (start + widget.pageSize).clamp(0, _filtered.length);
    if (start >= _filtered.length) return const [];
    return _filtered.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Title + header actions
            if (widget.title != null || widget.showHeaderActions)
              Row(
                children: [
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const Spacer(),
                  if (widget.showHeaderActions) ...[
                    TextButton.icon(
                      onPressed: _pageItems.isEmpty
                          ? null
                          : () => _selectAllOnPage(_pageItems),
                      icon: const Icon(Icons.task_alt),
                      label: const Text('Select page'),
                    ),
                    const SizedBox(width: 6),
                    TextButton.icon(
                      onPressed: _selected.isEmpty ? null : _clearSelection,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                  ],
                ],
              ),

            // Search
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),

            // Selected chips
            if (_selected.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _selected.map((it) {
                    final label = widget.itemLabel(it);
                    return Chip(
                      label: Text(label),
                      onDeleted: () => _toggle(it),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 8),

            // List with paging
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  // header row
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        const Icon(Icons.check_box, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Items',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text('${_filtered.length} found',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),

                  // items
                  if (_pageItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child:
                          Text('No results', style: theme.textTheme.bodyMedium),
                    )
                  else
                    ..._pageItems.map((it) {
                      final selected = _isSelected(it);
                      final label = widget.itemLabel(it);
                      return InkWell(
                        onTap: () => _toggle(it),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: theme.dividerColor.withOpacity(0.6)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: selected,
                                onChanged: (_) => _toggle(it),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  label,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              if (widget.trailingBuilder != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: widget.trailingBuilder!(it),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),

                  // footer / pager
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Page ${_page + 1} of $_pageCount',
                          style: theme.textTheme.bodySmall,
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Prev',
                          onPressed:
                              _page > 0 ? () => setState(() => _page--) : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        IconButton(
                          tooltip: 'Next',
                          onPressed: (_page + 1) < _pageCount
                              ? () => setState(() => _page++)
                              : null,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
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
