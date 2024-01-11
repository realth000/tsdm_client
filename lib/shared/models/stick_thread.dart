import 'package:tsdm_client/shared/models/normal_thread.dart';

class StickThread extends NormalThread {
  /// Build from node <tbody id="stickthread_xxx">.
  StickThread.fromTBody(super.element) : super.fromTBody();
}
