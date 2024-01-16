import 'package:equatable/equatable.dart';

class ReplyParameters extends Equatable {
  const ReplyParameters({
    required this.fid,
    required this.tid,
    required this.postTime,
    required this.formHash,
    required this.subject,
  });

  final String fid;
  final String tid;
  final String postTime;
  final String formHash;
  final String subject;

  @override
  String toString() {
    return 'ReplyParameters { fid=$fid, postTime=$postTime, formHash=$formHash, subject=$subject }';
  }

  @override
  List<Object?> get props => [fid, tid, postTime, formHash, subject];
}
