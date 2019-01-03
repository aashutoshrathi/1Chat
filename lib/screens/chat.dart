import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:gdg_gnr/utils/rich_text_view.dart';
import 'package:gdg_gnr/models/user.dart';
import 'package:gdg_gnr/screens/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gdg_gnr/screens/login.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/scheduler.dart';

class ChatList extends StatefulWidget {
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  User curUser;
  @override
  initState() {
    User user = Auth().getCurrentUser();
    if (user != null) {
      setState(() {
        curUser = user;
      });
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final msgController = TextEditingController();
  final scrollController = ScrollController();

  void _sendNewMsg(String msg, bool image) {
    var instance = Firestore.instance;
    CollectionReference ref = instance.collection('chat_133');
    ref.add({
      'id': '${curUser.id}',
      'img': '${curUser.imgURL}',
      'author': '${curUser.name}',
      'msg': '$msg',
      'timestamp': DateTime.now(),
      'isImage': image
    });
    msgController.clear();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 160,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 400),
    );
  }

  Future<Null> _pickAndSaveCamImage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child(curUser.id)
        .child("camera-${DateTime.now().millisecondsSinceEpoch}.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String imageURL = await taskSnapshot.ref.getDownloadURL();
    _sendNewMsg(imageURL, true);
  }

  Future<Null> _pickAndSaveGalleryImage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child(curUser.id)
        .child("gallery-${DateTime.now().millisecondsSinceEpoch}.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String imageURL = await taskSnapshot.ref.getDownloadURL();
    _sendNewMsg(imageURL, true);
  }

  void _openImage(BuildContext context, document) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => Scaffold(
              appBar: AppBar(
                title: Text('Image by ${document['author']}'),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () => print('pressed'),
                  )
                ],
              ),
              body: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 50.0,
                    ),
                    Hero(
                      tag: document['msg'],
                      child: CachedNetworkImage(
                        imageUrl: document['msg'],
                        placeholder: new CircularProgressIndicator(),
                        errorWidget: new Icon(Icons.error),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Sent by ${document['author']}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.w600),
                          ),
                          Text('at ${_fullDate(document['timestamp'])}'),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )));
  }

  void _showProfileImage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => Scaffold(
            appBar: AppBar(
              title: Text('${curUser.name}'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () => print('pressed'),
                )
              ],
            ),
            body: Center(
              child: Hero(
                tag: curUser.id,
                child: CachedNetworkImage(
                  imageUrl: curUser.imgURL,
                  placeholder: new CircularProgressIndicator(),
                  errorWidget: new Icon(Icons.error),
                ),
              ),
            ))));
  }

  String _date(DateTime timestamp) {
    return DateFormat.jm().format(timestamp);
  }

  String _fullDate(DateTime timestamp) {
    return DateFormat.jm().add_yMMMEd().format(timestamp);
  }

  Widget messageBox(String text) => GestureDetector(
        child: RichTextView(text: text),
        onLongPress: () => print('Delete?'),
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('1Chat β'),
          actions: <Widget>[
            Row(
              children: <Widget>[
                GestureDetector(
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(curUser.imgURL),
                  ),
                  onTap: () => _showProfileImage(context),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: GestureDetector(
                    child: Icon(Icons.exit_to_app, size: 30.0),
                    onTap: () {
                      Auth().signOut();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return LoginPage();
                      }));
                    },
                  ),
                )
              ],
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('chat_133').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: new Text('Loading...'));
                    default:
                      return new ListView(
                        controller: scrollController,
                        children: snapshot.data.documents
                            .map((DocumentSnapshot document) {
                          return Container(
                              child: Row(
                            mainAxisAlignment: document['id'] == curUser.id
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: document['id'] == curUser.id
                                    ? SizedBox()
                                    : CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                document['img']),
                                      ),
                              ),
                              Container(
                                // All styling here only
                                constraints: BoxConstraints(
                                  maxWidth: 200.0,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                    color: document['id'] == curUser.id
                                        ? Colors.blueAccent
                                        : Colors.black,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Column(
                                  crossAxisAlignment:
                                      document['id'] == curUser.id
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(bottom: 5.0),
                                      child: document['id'] == curUser.id
                                          ? SizedBox()
                                          : Text(
                                              document['author'].split(' ')[0],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15.0),
                                            ),
                                    ),
                                    document['isImage'] != null
                                        ? document['isImage']
                                            ? GestureDetector(
                                                onTap: () => _openImage(
                                                    context, document),
                                                child: Hero(
                                                    tag: document['msg'],
                                                    child: CachedNetworkImage(
                                                      imageUrl: document['msg'],
                                                      placeholder:
                                                          new CircularProgressIndicator(),
                                                      errorWidget:
                                                          new Icon(Icons.error),
                                                    )))
                                            : messageBox(document['msg'])
                                        : messageBox(document['msg']),
                                    Container(
                                      margin: document['isImage'] != null &&
                                              document['isImage']
                                          ? EdgeInsets.only(top: 10.0)
                                          : EdgeInsets.only(top: 3.0),
                                      child: Text(_date(document['timestamp']),
                                          textAlign: TextAlign.right,
                                          style: TextStyle(fontSize: 10.0)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ));
                        }).toList(),
                      );
                  }
                },
              ),
            ),
            Form(
                key: _formKey,
                // This thing goes to the bottom
                child: Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Material(
                    color: Colors.grey[600],
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20.0),
                    child: TextFormField(
                      validator: (String text) {
                        if (text.isEmpty) {
                          return 'What you tryin\' to send? :/';
                        }
                      },
                      controller: msgController,
                      decoration: InputDecoration(
                          prefixIcon: IconButton(
                            icon: Icon(Icons.camera),
                            onPressed: () => _pickAndSaveCamImage(),
                            color: Colors.white,
                            tooltip: 'Camera',
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send),
                            tooltip: 'Send',
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                _sendNewMsg(msgController.text, false);
                              }
                            },
                          ),
                          contentPadding:
                              EdgeInsets.only(left: 15.0, top: 15.0),
                          hintText: 'Type message here...'),
                    ),
                  ),
                )),
            SizedBox(
              height: 15.0,
            )
          ],
        ),
      ),
      theme: ThemeData.dark(),
    );
  }
}
