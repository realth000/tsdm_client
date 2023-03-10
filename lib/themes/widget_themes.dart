import 'package:flutter/material.dart';

/// Style for header text.
TextStyle headerTextStyle(BuildContext context) => const TextStyle(
      overflow: TextOverflow.fade,
      fontSize: 17,
    );

/// Small icon size.
const double smallIconSize = 18;

/// Small text size.
const double smallTextSize = 14;

/// Style for href text.
TextStyle hrefTextStyle(BuildContext context) => TextStyle(
      overflow: TextOverflow.fade,
      color: Theme.of(context).primaryColor,
    );
