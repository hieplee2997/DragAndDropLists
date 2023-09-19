import 'dart:async';

import 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item_target.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item_wrapper.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/programmatic_expansion_tile.dart';
import 'package:flutter/material.dart';

// typedef void OnExpansionChanged(bool expanded);

/// This class mirrors flutter's [ExpansionTile], with similar options.
class DragAndDropListExpansion implements DragAndDropListExpansionInterface {
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final bool initiallyExpanded;

  /// Set this to a unique key that will remain unchanged over the lifetime of the list.
  /// Used to maintain the expanded/collapsed states
  final Key listKey;

  /// This function will be called when the expansion of a tile is changed.
  // final OnExpansionChanged? onExpansionChanged;
  final ValueChanged<bool>? onExpansionChanged;

  final Color? backgroundColor;
  final List<DragAndDropItem>? children;
  final Widget? contentsWhenEmpty;
  final Widget? lastTarget;

  /// Whether or not this item can be dragged.
  /// Set to true if it can be reordered.
  /// Set to false if it must remain fixed.
  final bool canDrag;

  /// Disable to borders displayed at the top and bottom when expanded
  final bool disableTopAndBottomBorders;

  final bool pinnedTrailing;

  /// Function when right click 
  final Function()? firstFunction;
  final Function()? secondFunction;

  /// Title will show if function != null
  final String? titleFirstFunction;
  final String? titleSecondFunction;

  /// Icon will show if function != null
  final Widget? iconFirstFunction;
  final Widget? iconSecondFunction;

  /// number of function will show to user
  final int numberFunction;

  // this 2 variables help user show item they want when expansion tile contains item is collapse
  final itemSelectedInCollapse;
  final bool conditionToShowItemSelected;


  /// global key always recreate, so we need to pass from parent
  final GlobalKey<ProgrammaticExpansionTileState> expansionKey;
  GlobalKey<ProgrammaticExpansionTileState> get _expansionKey => this.expansionKey;
  
  ValueNotifier<bool> _expanded = ValueNotifier<bool>(true);

  DragAndDropListExpansion({
    this.children,
    this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.initiallyExpanded = false,
    this.backgroundColor,
    this.onExpansionChanged,
    this.contentsWhenEmpty,
    this.lastTarget,
    required this.listKey,
    this.canDrag = true,
    this.disableTopAndBottomBorders = false,
    this.pinnedTrailing = false,
    this.firstFunction,
    this.titleFirstFunction,
    this.titleSecondFunction,
    this.secondFunction,
    this.numberFunction = 0, 
    this.iconFirstFunction,
    this.iconSecondFunction,
    required this.expansionKey,
    this.conditionToShowItemSelected = false,
    this.itemSelectedInCollapse
  }) {
    _expanded.value = initiallyExpanded;
  }

  @override
  Widget generateWidget(DragAndDropBuilderParameters params) {
    var contents = _generateDragAndDropListInnerContents(params);

    Widget expandable = ProgrammaticExpansionTile(
      title: title,
      listKey: listKey,
      subtitle: subtitle,
      trailing: trailing,
      leading: leading,
      disableTopAndBottomBorders: disableTopAndBottomBorders,
      backgroundColor: backgroundColor,
      initiallyExpanded: initiallyExpanded,
      onExpansionChanged: _onSetExpansion,
      key: _expansionKey,
      children: contents,
      pinnedTrailing: pinnedTrailing,
      firstFunction: firstFunction,
      secondFunction: secondFunction,
      titleFirstFunction: titleFirstFunction,
      titleSecondFunction: titleSecondFunction,
      numberFunction: numberFunction,
      iconFirstFunction: iconFirstFunction,
      iconSecondFunction: iconSecondFunction,
      conditionToShowItemSelected: conditionToShowItemSelected,
      itemSelectedInCollapse: itemSelectedInCollapse,
    );

    if (params.listDecoration != null) {
      expandable = Container(
        decoration: params.listDecoration,
        child: expandable,
      );
    }

    if (params.listPadding != null) {
      expandable = Padding(
        padding: params.listPadding!,
        child: expandable,
      );
    }

    Widget toReturn = ValueListenableBuilder(
      valueListenable: _expanded,
      child: expandable,
      builder: (context, dynamic error, child) {
        if (!_expanded.value) {
          return Stack(children: <Widget>[
            child!,
            Positioned.fill(
              child: DragTarget<DragAndDropItem>(
                builder: (context, candidateData, rejectedData) {
                  if (candidateData.isNotEmpty) {}
                  return Container();
                },
                onWillAccept: (incoming) {
                  return true;
                },
                onLeave: (incoming) {},
                onAccept: (incoming) {
                  if (children != null && children!.isNotEmpty) {
                    params.onItemReordered!(incoming, children!.first);
                  } else {
                    children!.add(DragAndDropItem(child: Container(), feedbackWidget: Container()));
                    params.onItemReordered!(incoming, children!.first);
                  }
                },
              ),
            )
          ]);
        } else {
          return Stack(children: <Widget>[
            child!,
            Container(
              height: 55,
              child: DragTarget<DragAndDropItem>(
                builder: (context, candidateData, rejectedData) {
                  if (candidateData.isNotEmpty) {}
                  return Container();
                },
                onWillAccept: (incoming) {
                  return true;
                },
                onLeave: (incoming) {},
                onAccept: (incoming) {
                  if (children != null && children!.isNotEmpty) {
                    params.onItemReordered!(incoming, children!.first);
                  } else {
                    children!.add(DragAndDropItem(child: Container(), feedbackWidget: Container()));
                    params.onItemReordered!(incoming, children!.first);
                  }
                },
              ),
            ),
          ]);
        }
      },
    );

    return toReturn;
  }

  Widget generateWigetWithoutChildren() {
    return Container();
  }

  List<Widget> _generateDragAndDropListInnerContents(
      DragAndDropBuilderParameters parameters) {
    var contents = <Widget>[];
    if (children != null && children!.isNotEmpty) {
      for (int i = 0; i < children!.length; i++) {
        contents.add(DragAndDropItemWrapper(
          child: children![i],
          parameters: parameters,
        ));
        if (parameters.itemDivider != null && i < children!.length - 1) {
          contents.add(parameters.itemDivider!);
        }
      }
      contents.add(DragAndDropItemTarget(
        parent: this,
        parameters: parameters,
        onReorderOrAdd: parameters.onItemDropOnLastTarget!,
        child: lastTarget ??
            Container(
              height: parameters.lastItemTargetHeight,
            ),
      ));
    } else {
      contents.add(
        contentsWhenEmpty ??
            Text(
              'Empty list',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
      );
      contents.add(
        DragAndDropItemTarget(
          parent: this,
          parameters: parameters,
          onReorderOrAdd: parameters.onItemDropOnLastTarget!,
          child: lastTarget ??
              Container(
                height: parameters.lastItemTargetHeight,
              ),
        ),
      );
    }
    return contents;
  }

  @override
  toggleExpanded() {
    if (isExpanded)
      collapse();
    else
      expand();
  }

  @override
  collapse() {
    if (!isExpanded) {
      _expanded.value = false;
      _expansionKey.currentState!.collapse();
    }
  }

  @override
  expand() {
    if (!isExpanded) {
      _expanded.value = true;
      _expansionKey.currentState!.expand();
    }
  }

  _onSetExpansion(bool expanded) {
    _expanded.value = expanded;

    if (onExpansionChanged != null) onExpansionChanged!(expanded);
  }

  @override
  get isExpanded => _expanded.value;

  late Timer _expansionTimer;

  _startExpansionTimer() async {
    _expansionTimer = Timer(Duration(milliseconds: 400), _expansionCallback);
  }

  _stopExpansionTimer() async {
    if (_expansionTimer.isActive) {
      _expansionTimer.cancel();
    }
  }

  _expansionCallback() {
    expand();
  }
}
