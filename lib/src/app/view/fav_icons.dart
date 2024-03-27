// Copyright 2023 Andrious Solutions Ltd. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show kDebugMode;

import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';

import 'package:workingmemory/src/controller.dart';

import 'package:workingmemory/src/model.dart' hide Icon, Icons;

import 'package:workingmemory/src/view.dart' hide ColorPicker;

/// Edit and arrange your favourite icons.
class FavIcons extends StatefulWidget {
  ///
  const FavIcons({super.key});

  @override
  State<StatefulWidget> createState() => _FavIconsState();
}

class _FavIconsState extends State<FavIcons> {
  //

  @override
  void initState() {
    super.initState();

    final List<Map<String, dynamic>>? favIcons = Controller().favIcons;

    if (favIcons != null) {
      //
      for (final fav in favIcons) {
        //
        for (final icon in fav.entries) {
          //
          _listOfDraggableGridItem.add(DraggableGridItem(
            child: Card(
              child: Icon(
                  size: 48,
                  IconData(int.parse(icon.value), fontFamily: 'MaterialIcons')),
            ),
            isDraggable: true,
            // dragCallback: (context, isDragging) {
            //   if (kDebugMode) {
            //     print('isDragging: $isDragging');
            //   }
            // },
          ));
        }
      }
    }
  }

  final List<DraggableGridItem> _listOfDraggableGridItem = [];
  final ScrollController _scrollController = ScrollController();
  late Size screenSize;

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Favorite Icons'.tr),
        bottom: trashCan,
      ),
      body: SafeArea(
        child: DraggableGridViewBuilder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: screenSize.width / (screenSize.height / 3),
          ),
          children: _listOfDraggableGridItem,
          dragCompletion: onDragAccept,
          dragFeedback: feedback,
          dragPlaceHolder: placeHolder,
        ),
      ),
    );
  }

  Widget feedback(List<DraggableGridItem> list, int index) => SizedBox(
        width: 47.w,
        height: 15.h,
        child: _favCard(list, index),
      );

  PlaceHolderWidget placeHolder(List<DraggableGridItem> list, int index) {
    return PlaceHolderWidget(
      child: Card(
        elevation: 3,
        child: Container(
          color: Colors.white,
        ),
      ),
    );
  }

  Card _favCard(List<DraggableGridItem> list, int index) {
    final child = list[index].child;
    Card card;
    if (child is PlaceHolderWidget) {
      card = child.child as Card;
    } else {
      card = child as Card;
    }
    return Card(
      elevation: 3,
      child: card.child,
    );
  }

  void onDragAccept(
    List<DraggableGridItem> list,
    int beforeIndex,
    int afterIndex,
  ) {
    if (kDebugMode) {
      print('onDragAccept: $beforeIndex -> $afterIndex');
    }
  }

  ///
  PreferredSizeWidget? get trashCan {
    //
    final leftSided = Settings.leftSided;

    return PreferredSize(
      preferredSize: const Size(75, 75),
      child: Row(
          mainAxisAlignment:
              leftSided ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
//            if (leftSided) const SizedBox(width: 10),

            DragTarget<int>(
              onAccept: (int? index) {},
//              onLeave: (details) {},
              onWillAccept: (int? index) {
                /// Drag is acceptable in this index else this place.
                return true;
              },
              onMove: (details) {
                if (kDebugMode) {
                  print('test');
                }
              },
              builder: (
                BuildContext context,
                List<dynamic> accepted,
                List<dynamic> rejected,
              ) {
                return Expanded(
                  child: Container(
                    width: 100.w,
                    height: 10.h,
                    color: Colors.red,
                    child: const Text('fill the remaining space'),
                  ),
                );
                return SizedBox(
                  width: 50,
                  height: 60,
                  child: Icon(
                    Icons.delete,
                    size: App.useCupertino ? 22 : null,
                    color: App.useCupertino ? null : Colors.white,
                  ),
                );
              },
            ),
//            if (!leftSided) const SizedBox(width: 10),
          ]),
    );
  }
}
