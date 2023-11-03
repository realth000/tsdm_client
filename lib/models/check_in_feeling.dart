import 'package:flutter/material.dart';
import 'package:tsdm_client/generated/i18n/strings.g.dart';

enum CheckInFeeling {
  happy,
  sad,
  depressed,
  boring,
  angry,
  speechless,
  struggle,
  lazy,
  unlucky;

  factory CheckInFeeling.from(String feeling) {
    return switch (feeling) {
      'kx' => CheckInFeeling.happy,
      'ng' => CheckInFeeling.sad,
      'ym' => CheckInFeeling.depressed,
      'wl' => CheckInFeeling.boring,
      'nu' => CheckInFeeling.angry,
      'ch' => CheckInFeeling.speechless,
      'fd' => CheckInFeeling.struggle,
      'yl' => CheckInFeeling.lazy,
      'shuai' => CheckInFeeling.unlucky,
      String() => CheckInFeeling.happy,
    };
  }

  @override
  String toString() {
    return switch (this) {
      CheckInFeeling.happy => 'kx',
      CheckInFeeling.sad => 'ng',
      CheckInFeeling.depressed => 'ym',
      CheckInFeeling.boring => 'wl',
      CheckInFeeling.angry => 'nu',
      CheckInFeeling.speechless => 'ch',
      CheckInFeeling.struggle => 'fd',
      CheckInFeeling.lazy => 'yl',
      CheckInFeeling.unlucky => 'shuai',
    };
  }

  String translate(BuildContext context) {
    return switch (this) {
      CheckInFeeling.happy => context.t.feelingList.happy,
      CheckInFeeling.sad => context.t.feelingList.sad,
      CheckInFeeling.depressed => context.t.feelingList.depressed,
      CheckInFeeling.boring => context.t.feelingList.boring,
      CheckInFeeling.angry => context.t.feelingList.angry,
      CheckInFeeling.speechless => context.t.feelingList.speechless,
      CheckInFeeling.struggle => context.t.feelingList.struggling,
      CheckInFeeling.lazy => context.t.feelingList.lazy,
      CheckInFeeling.unlucky => context.t.feelingList.unlucky,
    };
  }
}
