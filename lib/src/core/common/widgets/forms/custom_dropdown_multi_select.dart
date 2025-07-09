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
  bool _isDropdownOpen = false;

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _onItemTapped(T item) {
    setState(() {
      final newList = List<T>.from(widget.selectedItems);
      if (newList.contains(item)) {
        newList.remove(item);
      } else {
        newList.add(item);
      }
      widget.onChanged(newList);
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.selectedItems.isNotEmpty
        ? widget.selectedItems.map(widget.getLabel).join(', ')
        : widget.hint ?? 'Select options';

    return Column(
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
                _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              ),
            ),
            child: Text(
              displayText,
              style: TextStyle(
                color: widget.selectedItems.isNotEmpty
                    ? Colors.black
                    : Colors.grey[600],
              ),
            ),
          ),
        ),
        if (_isDropdownOpen)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 6),
              children: widget.items.map((item) {
                final isSelected = widget.selectedItems.contains(item);
                return InkWell(
                  onTap: () => _onItemTapped(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? Colors.blue.shade50 : Colors.transparent,
                    ),
                    child: Text(
                      widget.getLabel(item),
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
