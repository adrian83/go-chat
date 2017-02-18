import 'dart:html';

import 'ws_client.dart';
import 'channel_tabs.dart';
import 'channel_list.dart';
import 'messages.dart';
import 'errors.dart';
import 'html_utils.dart';

main() {



  InputElement element = querySelector("#session-id");
  var sessionId = element.value;

  var wssocket = new WebSocket("ws://localhost:7070/talk");

  var client = new WSClient(sessionId, wssocket);
  var channelManager = new ChannelsManager(sessionId);
  var channelList = new NewChannelList();
  var errorsPanel = new ErrorsPanel();

  client.start();

  void sendTextMessage(TMessage tMsg) {
    var msg = new TextMsg(sessionId, "x", tMsg.text, tMsg.channel);
    client.send(msg.toJSON());
  }

  client.messages.listen((msg) => print("Data: " + msg.toString()));
  client.messages.listen((msg) => channelManager.onMessage(msg));
  client.messages.listen((msg) => channelList.onMessage(msg));

  void onSocketClose() {
    //hideElement("#panels");
    //hideElement("#logout-info");
    //var errMsg = new ErrorMsg("system", "system", "Connection has been closed. Maybe server is down.");
    //errorsPanel.onMessage(errMsg);
    print("socket close");
    window.location.assign('/?reason=logout');
  }

  client.close.listen((b) => onSocketClose());
  client.open.listen((b) => hideElement("#connection-info"));
  client.errors.listen((b) => onSocketClose() );

  void onMsg(Message msg) {
    if(msg is LogoutMsg) {
      client.closeClient();
      //window.location.assign('/');
    }
  }

  channelManager.closedTabs.listen((name) => print("Tab closed: " + name));
  channelManager.loggedOut.listen((b) => client.logout());
  channelManager.messages.listen((msg) => onMsg(msg));




}
