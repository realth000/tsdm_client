import 'package:flutter/material.dart';

const sizedBoxW5H5 = SizedBox(width: 5, height: 5);
const sizedBoxW10H10 = SizedBox(width: 10, height: 10);
const sizedBoxW20H20 = SizedBox(width: 20, height: 20);

const edgeInsetsT10 = EdgeInsets.only(top: 10);
const edgeInsetsL10R10 = EdgeInsets.only(left: 10, right: 10);
const edgeInsetsL15R15 = EdgeInsets.only(left: 15, right: 15);
const edgeInsetsL18R18 = EdgeInsets.symmetric(horizontal: 18);
const edgeInsetsL10T10R10 = EdgeInsets.only(left: 10, top: 10, right: 10);
const edgeInsetsL10R10B10 = EdgeInsets.only(left: 10, right: 10, bottom: 10);
const edgeInsetsL10R10B20 = EdgeInsets.only(left: 10, right: 10, bottom: 20);
const edgeInsetsL15R15B10 = EdgeInsets.only(left: 15, right: 15, bottom: 10);
const edgeInsetsL10T5R5B5 =
    EdgeInsets.only(left: 10, top: 5, right: 5, bottom: 5);
const edgeInsetsL10T5R10B20 =
    EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 20);
const sizedCircularProgressIndicator = SizedBox(
  width: 16,
  height: 16,
  child: CircularProgressIndicator(strokeWidth: 3),
);
