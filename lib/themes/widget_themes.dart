import 'package:flutter/material.dart';

/// Small icon size.
const double smallIconSize = 18;

/// Small text size.
const double smallTextSize = 14;

/// Style for href text.
TextStyle hrefTextStyle(BuildContext context) =>
    TextStyle(overflow: TextOverflow.fade, color: Theme.of(context).primaryColor);
