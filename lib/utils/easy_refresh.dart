import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';

ScrollBehavior buildScrollBehavior(ScrollPhysics? physics) =>
    ERScrollBehavior(physics).copyWith(
      physics: physics,
      scrollbars: false,
    );

const header = MaterialHeader(position: IndicatorPosition.locator);
const footer = ClassicFooter(position: IndicatorPosition.locator);
