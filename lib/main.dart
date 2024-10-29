import 'package:flutter/material.dart';

/// Entry point of the application.
void main() {
  runApp(const MyApp());
}

/// Main application widget building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[icon.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(icon, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A customizable dock widget that displays reorderable [items].
///
/// The [Dock] widget accepts a list of items and a builder function
/// to display them in a reorderable layout. It supports dragging
/// items within the dock and returning items to their original position
/// if dropped outside.
class Dock<T extends Object> extends StatefulWidget {
  /// Creates a [Dock] widget with an initial list of [items] and a [builder]
  /// function to display each item.
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// The initial list of items displayed in the dock.
  final List<T> items;

  /// A builder function that defines how each item in the dock is displayed.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// The state for the [Dock] widget.
///
/// [_DockState] manages the item list and provides functionality to handle
/// drag and drop interactions within the dock.
class _DockState<T extends Object> extends State<Dock<T>> {
  /// A copy of the initial [items] list to manipulate during drag operations.
  late final List<T> _items = widget.items.toList();

  /// The item currently being dragged.
  T? _draggedItem;

  /// The original index of the item being dragged.
  int? _originalIndex;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) => _buildDraggableItem(entry.key)).toList(),
      ),
    );
  }

  /// Builds a draggable item at the specified [index].
  ///
  /// This widget uses [LongPressDraggable] to allow reordering of items
  /// within the dock. When an item is dragged, it temporarily hides in its
  /// original position.
  Widget _buildDraggableItem(int index) {
    final item = _items[index];

    return LongPressDraggable<T>(
      data: item,
      feedback: Material(child: widget.builder(item)),
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: () {
        setState(() {
          _draggedItem = item;
          _originalIndex = index;
        });
      },
      onDragEnd: (details) {
        setState(() {
          _draggedItem = null;
          _originalIndex = null;
        });
      },
      child: DragTarget<T>(
        onAcceptWithDetails: (details) {
          final draggedItem = details.data;
          setState(() {
            final draggedIndex = _items.indexOf(draggedItem);
            _items.removeAt(draggedIndex);
            _items.insert(index, draggedItem);
            _draggedItem = null;
          });
        },
        onWillAcceptWithDetails: (data) => true,
        builder: (context, candidateData, rejectedData) {
          return (_draggedItem == item)
              ? const SizedBox.shrink()
              : widget.builder(item);
        },
      ),
    );
  }
}
