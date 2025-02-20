part of 'models.dart';

/// Model of a packet detail status.
///
/// Each model instance related to an event of receiving packet in thread.
@MappableClass()
final class PacketDetailModel with PacketDetailModelMappable {
  /// Constructor.
  const PacketDetailModel({
    required this.id,
    required this.uid,
    required this.username,
    required this.coins,
    required this.time,
  });

  /// Build a model from tr node.
  ///
  /// ```html
  /// <tr>
  ///   <td>$ID</td>
  ///   <td>$UID</td>
  ///   <td>$USERNAME</td>
  ///   <td>$COINS</td>
  ///   <td>$TIME</td>
  /// </tr>
  /// ```
  static PacketDetailModel? fromTr(uh.Element element) {
    final trList = element.querySelectorAll('td');
    if (trList.length != 5) {
      talker.error(
        'failed to build packet detail from tr node: '
        'incorrect tr count ${trList.length}',
      );
      return null;
    }

    final id = int.tryParse(trList.first.innerText);
    final uid = int.tryParse(trList.elementAt(1).innerText);
    final username = trList.elementAt(2).innerText.trim();
    final coins = int.tryParse(trList.elementAt(3).innerText);
    final time = DateTime.tryParse(trList.elementAt(4).innerText);

    if (id == null || uid == null || username.isEmpty || coins == null || time == null) {
      talker.error(
        'failed to build packet detail from tr node: '
        'id=$id, uid=$uid, username=$username, coins=$coins, time=$time',
      );
      return null;
    }

    return PacketDetailModel(id: id, uid: uid, username: username, coins: coins, time: time);
  }

  /// Event id in thread.
  final int id;

  /// User id of who received the packet.
  final int uid;

  /// Username of who received the packet.
  final String username;

  /// Coins received in the event.
  final int coins;

  /// Time of the event.
  ///
  /// In format yyyy-mm-dd HH:MM:SS
  final DateTime time;
}
