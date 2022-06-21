// import 'package:flutter/material.dart';
// import 'package:pubnub/pubnub.dart';
// import 'package:uuid/uuid.dart';
// // import 'package:pubnub/src/dx/subscribe/extensions/keyset.dart';
//
// // https://ps.pndsn.com/v3/history/sub-key/sub-c-4e1db676-b739-11e8-8c7a-8a442d951856/channel/channel-1543321859-089d02311fed67dbd3ac672c2b3dbf50
//
//
// class AppChannels {
//   final Channel system;
//
//   AppChannels(PubNub pubnub, UUID uuid)
//       : system = pubnub.channel('system.${uuid.value}');
// }
//
// class AppSubscriptions {
//   Subscription system;
//   Subscription friends;
//   Subscription me;
// }
//
// class Conversation {
//   PaginatedChannelHistory from;
//   PaginatedChannelHistory to;
//
//   String me;
//   String them;
//
//   List<Message> get messages => ([...from.messages, ...to.messages]
//         ..sort((m1, m2) => m1.timetoken.value.compareTo(m2.timetoken.value)))
//       .reversed
//       .toList();
//
//   Conversation(this.from, this.to, this.me, this.them);
//
//   Future<void> more() async {
//     await from.more();
//     await to.more();
//   }
//
//   void reset() {
//     from.reset();
//     to.reset();
//   }
// }
//
// class PubNubApp {
//   static final _instance = PubNubApp._internal();
//   factory PubNubApp() => _instance;
//
//   PubNub _pubnub = PubNub();
//   PubNub get pubnub => _pubnub;
//
//   PubNubApp._internal();
//
//   AppChannels channels;
//   AppSubscriptions subs = AppSubscriptions();
//
//   bool _isInitialized = false;
//
//   Future<void> init(Keyset keyset) async {
//     debugPrint('trying to init');
//     if (_isInitialized == false) {
//       _isInitialized = true;
//       _pubnub.keysets.add(keyset, name: 'default', useAsDefault: true);
//
//       channels = AppChannels(_pubnub, keyset.uuid);
//
//       subs.system = await channels.system.subscribe();
//       subs.me = await pubnub
//           .subscribe(channels: {'${keyset.uuid}.*'}, withPresence: false);
//
//       // keyset.subscriptionManager.messages.listen((msg) {
//       //   print('$msg');
//       // });
//
//       debugPrint('Subscribing to self: ${keyset.uuid}.* ');
//     }
//     else {
//       _pubnub.keysets.remove('default');
//       subs.system.unsubscribe();
//       _isInitialized = false;
//       init(keyset);
//     }
//   }
//
//   Future<dynamic> request(String type, [dynamic payload]) async {
//     var requestId = Uuid().v4();
//
//     var result = subs.system.messages
//         .firstWhere((envelope) => envelope.payload['responseId'] == requestId);
//
//     channels.system.publish({
//       'requestId': requestId,
//       'type': type,
//       if (payload != null) 'payload': payload
//     });
//
//     return (await result).payload;
//   }
//
//   Subscription get self => subs.me;
//
//   Future<void> announceFriends(String myUuid, List<String> uuids) async {
//     if (subs.friends != null) {
//       subs.friends.unsubscribe();
//     }
//
//     var channels = uuids.map((uuid) => '$uuid.$myUuid').toSet();
//
//     await pubnub.announceHeartbeat(channels: channels, heartbeat: 60);
//   }
//
//   Future<List<String>> activeFriends(String myUuid, List<String> uuids) async {
//     var result = await pubnub.hereNow(
//         channels: uuids.map((uuid) => '$myUuid.$uuid').toSet());
//
//     return uuids.where((uuid) {
//       var channelOccupation = result.channels['$myUuid.$uuid'];
//
//       return channelOccupation.uuids.containsKey(uuid);
//     }).toList();
//   }
//
//   Conversation getConversation(String myUuid, String theirUuid) {
//     var toChannel = pubnub.channel('$myUuid.$theirUuid');
//     var fromChannel = pubnub.channel('$theirUuid.$myUuid');
//
//     var toHistory = toChannel.history(chunkSize: 50);
//     var fromHistory = fromChannel.history(chunkSize: 50);
//
//     var conversation = Conversation(fromHistory, toHistory, myUuid, theirUuid);
//
//     return conversation;
//   }
// }
