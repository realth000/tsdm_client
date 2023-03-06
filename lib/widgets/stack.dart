import 'package:flutter/material.dart';

/// Build a [Stack] that mapped [widget] and [floatingWidget]
Stack buildStack(Widget widget, Widget floatingWidget) => Stack(
      alignment: Alignment.bottomRight,
      children: [
        widget,
        Positioned(
          right: 20,
          bottom: 20,
          child: floatingWidget,
        ),
      ],
    );
