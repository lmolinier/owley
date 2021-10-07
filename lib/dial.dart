import 'package:demogonio/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class DialMenu extends StatefulWidget {
  const DialMenu({Key? key, required this.parent, this.body}) : super(key: key);

  final MyHomePageState parent;
  final Widget? body;

  @override
  State<DialMenu> createState() => _DialMenuState();
}

class _DialMenuState extends State<DialMenu> {
  ValueNotifier<bool> isOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isOpen.value) {
          isOpen.value = false;
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          openCloseDial: isOpen,
          backgroundColor: Colors.redAccent,
          overlayColor: Colors.grey,
          overlayOpacity: 0.5,
          spacing: 15,
          spaceBetweenChildren: 15,
          closeManually: false,
          children: [
            SpeedDialChild(
                child: const Icon(Icons.layers),
                label: 'Type',
                onTap: () {
                  widget.parent.toggleMapType();
                }),
            SpeedDialChild(
                child: !widget.parent.isCenterLocked()
                    ? const Icon(Icons.center_focus_strong)
                    : const Icon(Icons.control_camera),
                label: !widget.parent.isCenterLocked() ? "Lock" : "Free",
                backgroundColor: Colors.teal[200],
                onTap: () {
                  widget.parent.toggleCenterLock();
                  setState(() {});
                }),
            SpeedDialChild(
                child: const Icon(Icons.delete_sweep),
                label: 'Reset',
                onTap: () {
                  widget.parent.clearPolygons();
                }),
            SpeedDialChild(
                child: const Icon(Icons.delete),
                label: 'Delete last',
                onTap: () {
                  widget.parent.removeLastPolygon();
                }),
          ],
        ),
        body: widget.body!,
      ),
    );
  }
}
