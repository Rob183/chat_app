import 'dart:html';

import 'package:chat_app/screens/components/roundedButtonW.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const id = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  late String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').get();
  //   for (var messages in messages.docs) {
  //     print(messages.data());
  //   }
  // }

  // void messagesStream() async {
  //   await for (var snapshot in _firestore.collection("messages").snapshots()) {
  //     for (var messages in snapshot.docs) {
  //       print(messages.data());
  //     }
  //   }
  // }
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('messages').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
          IconButton(
              icon: Icon(Icons.open_in_browser),
              onPressed: () {
                // messagesStream();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SizedBox(
                child: Builder(),
                height: 200.0,
              ),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                        'time': DateTime.now().toString(),
                      });
                      messageTextController.clear();
                      print(DateTime.now());
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Builder extends StatelessWidget {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('messages')
      .orderBy("time")
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.lightBlueAccent,
          ));
        }

        return ListView(
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          children: snapshot.data!.docs.reversed
              .map((DocumentSnapshot document) {
                final currentUser = loggedInUser.email;
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                final bool isme;
                if (data['sender'] == currentUser) {
                  isme = false;
                } else {
                  isme = true;
                }
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: isme
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(data['sender'],
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54)),
                      ),
                      Material(
                          borderRadius: isme
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30))
                              : BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30)),
                          elevation: 5.0,
                          color:
                              isme ? Colors.blueAccent : Colors.lightBlueAccent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              data['text'],
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                    ],
                  ),
                );
              })
              .toList()
              .cast(),
        );
      },
    );
  }
}
