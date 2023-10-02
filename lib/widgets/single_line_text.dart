import 'package:flutter/material.dart';

class SingleLineText extends Text {
  const SingleLineText(
    super.data, {
    super.key,
    super.overflow = TextOverflow.clip,
    super.maxLines = 1,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.textDirection,
    super.locale,
    super.softWrap,
    super.textScaleFactor,
    super.semanticsLabel,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
  });
}
