import 'dart:async';

import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:drag_and_drop_lists/programmatic_expansion_tile.dart';
import 'package:example/navigation_drawer.dart' as navi;
import 'package:flutter/material.dart';

class ExpansionTileExample extends StatefulWidget {
  const ExpansionTileExample({Key? key}) : super(key: key);

  @override
  State createState() => _ListTileExample();
}

class InnerList {
  final String name;
  List<String> children;
  InnerList({required this.name, required this.children});
}

class _ListTileExample extends State<ExpansionTileExample> {
  late List<InnerList> _lists;

  bool isChannelHide = false;

  @override
  void initState() {
    super.initState();

    _lists = List.generate(10, (outerIndex) {
      return InnerList(
        name: outerIndex.toString(),
        children: List.generate(6, (innerIndex) => '$outerIndex.$innerIndex'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Timer.periodic(Duration(seconds: 1), (timer) {
    //   setState(() {
        
    //   });
    //  });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expansion Tiles'),
      ),
      drawer: const navi.NavigationDrawer(),
      body: DragAndDropLists(
        children: List.generate(_lists.length, (index) => _buildList(index)),
        onItemReorder: _onItemReorder,
        onListReorder: _onListReorder,
        itemDragOnLongPress: false,
        listDragOnLongPress: false,
        contentsWhenEmpty: const SizedBox.shrink(),
        listDecorationWhileDragging: BoxDecoration(
          color: Colors.blue,
        ),
        // listTargetOnAccept: (incoming, target) {
        //   // print('listTargetOnAccept:$incoming');
        //   // print('target:$target');
        //   print('listTargetOnAccept');
        // },
        // onListDraggingChanged: (list, dragging) {
        //   print('onListDraggingChanged');

        // },
        // onListAdd: (newList, newListIndex) {
        //   print('onListAdd');
          
        // },
        listOnWillAccept: (incoming, target) {
          print('listOnWillAccept');
          return false;
        },
        // listTargetOnWillAccept:(incoming, target) {
        //   print('listTargetOnWillAccept');
        //   return true;
        // },
        // listOnAccept: (incoming, target) {
        //   print('listOnAccept');
        // },
        // onItemAdd: (newItem, listIndex, newItemIndex) {
        //   print('onItemAdd');
        // },
        // itemOnAccept: (incoming, target) {
        //   print('itemOnAccept');
        // },
        // onItemDraggingChanged:(item, dragging) {
        //   print('onItemDraggingChanged');
        // },
        // itemOnWillAccept: (incoming, target) {
        //   print('itemOnWillAccept');
        //   if (incoming is DragAndDropItem) {
        //     print('itemDrag');
        //     // return true;
        //   }    
        //   return true;
        // },
        // itemTargetOnWillAccept: (incoming, target) {
        //   print('itemTargetOnWillAccept');    
        //   return true;
        // },
        // itemTargetOnAccept: (incoming, parentList, target) {
        //   print('itemTargetOnAccept');  
        // },
        // disableScrolling: true,
        // listGhost is mandatory when using expansion tiles to prevent multiple widgets using the same globalkey
        listGhost: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Divider(
            color: Color.fromARGB(197, 8, 246, 16),
            indent: 10,
            thickness: 3.0,
          ),
        )
      ),
      ),
    );
  }

  _buildList(int outerIndex) {
    var innerList = _lists[outerIndex];
    return DragAndDropListExpansion(
      expansionKey: GlobalKey<ProgrammaticExpansionTileState>(),
      title: Text('List ${innerList.name}'),
      subtitle: Text('Subtitle ${innerList.name}'),
      leading: const Icon(Icons.ac_unit),
      canDrag: outerIndex <= 1 ? false : true,
      firstFunction: () {
        print('1');
      },
      titleFirstFunction: "1",
      secondFunction: () {
        print('2');
      },
      titleSecondFunction: "2",
      numberFunction: 1,
      // pinnedTrailing: outerIndex <= 3 ? true : false,
      children: List.generate(innerList.children.length,
          (index) => _buildItem(innerList.children[index])),
      listKey: ObjectKey(innerList),
    );
  }

  _buildItem(String item) {
    return DragAndDropItem(
      child: Container(
        color: isChannelHide ? Colors.grey : null,
        child: ListTile(
          title: TextTest(text: item),
        ),
      ),
    );
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    
    print('oldItemIndex:$oldItemIndex');
    print('oldListIndex:$oldListIndex');
    print('newItemIndex:$newItemIndex');
    print('newListIndex:$newListIndex');
    setState(() {
      var movedItem = _lists[oldListIndex].children.removeAt(oldItemIndex);
      _lists[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _lists.removeAt(oldListIndex);
      _lists.insert(newListIndex, movedList);
    });
  }
}

class TextTest extends StatefulWidget {
  const TextTest({super.key, required this.text});
  final String text;

  @override
  State<TextTest> createState() => TextTestState();
}

class TextTestState extends State<TextTest> {
  @override
  void initState() {
    // print('inittt');
    super.initState();
  }

  @override void dispose() {
    // print('dissss');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "${widget.text}"
    );
  }
}
