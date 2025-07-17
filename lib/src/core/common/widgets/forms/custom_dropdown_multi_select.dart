import 'package:flutter/material.dart';

class CustomMultiDropdownList<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;
  final void Function(List<T>) onChanged;
  final String Function(T) getLabel;
  final String label;
  final String? hint;

  const CustomMultiDropdownList({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    required this.getLabel,
    required this.label,
    this.hint,
  });

  @override
  State<CustomMultiDropdownList<T>> createState() =>
      _CustomMultiDropdownListState<T>();
}

class _CustomMultiDropdownListState<T>
    extends State<CustomMultiDropdownList<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late List<T> _localSelected;

  @override
  void initState() {
    super.initState();
    _localSelected = List<T>.from(widget.selectedItems);
  }

  @override
  void didUpdateWidget(covariant CustomMultiDropdownList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // keep local selection in sync with parent when parent updates
    _localSelected = List<T>.from(widget.selectedItems);
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isOpen = true;
  }

  void _onItemTapped(T item) {
    setState(() {
      if (_localSelected.contains(item)) {
        _localSelected.remove(item);
      } else {
        _localSelected.add(item); // no duplicates
      }
    });
    widget.onChanged(List<T>.from(_localSelected));
    // rebuild overlay so highlight updates instantly
    _overlayEntry?.markNeedsBuild();
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _removeOverlay, // tap outside closes
          child: Stack(
            children: [
              Positioned(
                width: size.width,
                left: offset.dx,
                top: offset.dy + size.height + 5,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(0, size.height + 5),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: widget.items.map((item) {
                          final isSelected = _localSelected.contains(item);
                          return InkWell(
                            onTap: () => _onItemTapped(item),
                            child: Container(
                              color: isSelected
                                  ? Colors.blue.shade50
                                  : Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              child: Text(
                                widget.getLabel(item),
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color:
                                      isSelected ? Colors.blue : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _localSelected.isNotEmpty
        ? _localSelected.map(widget.getLabel).join(', ')
        : (widget.hint ?? 'Select options');

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _toggleDropdown,
            child: InputDecorator(
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                suffixIcon: Icon(
                  _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
              ),
              child: Text(
                displayText,
                style: TextStyle(
                  color: _localSelected.isNotEmpty
                      ? Colors.black
                      : Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
}
