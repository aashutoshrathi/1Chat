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

class ChatList extends StatefulWidget {
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  initState() {
    User user = Auth().getCurrentUser();
    if (user != null) {
      setState(() {
        curUser = user;
      });
    }
    super.initState();
  }

  User curUser;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  bool isUploading = false;
  double progress;

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
    _msgController.clear();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 100),
    );
  }

  void _deleteMsg(String docID) {
    var instance = Firestore.instance;
    CollectionReference ref = instance.collection('chat_133');
    ref.document(docID).delete().catchError((e) => print(e));
  }

  Future<Null> _pickAndUploadImage(int choice) async {
    String filename = choice == 0
        ? "camera-${DateTime.now().millisecondsSinceEpoch}.jpg"
        : "gallery-${DateTime.now().millisecondsSinceEpoch}.jpg";
    File imageFile = await ImagePicker.pickImage(
        source: choice == 0 ? ImageSource.camera : ImageSource.gallery);
    if (imageFile.path != null) {
      StorageReference ref =
          FirebaseStorage.instance.ref().child(curUser.id).child(filename);
      StorageUploadTask uploadTask = ref.putFile(imageFile);
      uploadTask.events.listen((event) {
        setState(() {
          isUploading = true;
          progress = (event.snapshot.bytesTransferred.toDouble() /
                  event.snapshot.totalByteCount.toDouble()) *
              100;
        });
      }).onError((error) {
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text(error.toString()),
          backgroundColor: Colors.red,
        ));
      });

      uploadTask.onComplete.then((snapshot) {
        setState(() {
          isUploading = false;
        });
      });
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      String imageURL = await taskSnapshot.ref.getDownloadURL();
      _sendNewMsg(imageURL, true);
    }
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
                        placeholder: CircularProgressIndicator(),
                        errorWidget: Icon(Icons.error),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 200.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                  imageUrl: curUser.imgURL.replaceAll('s96-c', 's400-c'),
                  // Increase image size
                  placeholder: CircularProgressIndicator(),
                  errorWidget: Icon(Icons.error),
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

  Widget _messageBox(String text, String docID, bool userCheck) =>
      GestureDetector(
        child: RichTextView(text: text),
        onLongPress: () => userCheck
            ? showDialog(
                context: context,
                builder: (BuildContext context) =>
                    _buildDeleteDialog(context, docID),
              )
            : print('Hello'),
      );

  Widget _messageContent(doc) => doc['isImage'] != null && doc['isImage']
      ? GestureDetector(
          onTap: () => _openImage(context, doc),
          onLongPress: () => doc['id'] == curUser.id
              ? showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildDeleteDialog(context, doc.documentID),
                )
              : print('Hello'),
          child: Hero(
              tag: doc['msg'],
              child: CachedNetworkImage(
                imageUrl: doc['msg'],
                placeholder: CircularProgressIndicator(),
                errorWidget: Icon(Icons.error),
              )))
      : _messageBox(doc['msg'], doc.documentID, doc['id'] == curUser.id);

  Widget _timeStamp(doc) => Container(
        margin: doc['isImage'] != null && doc['isImage']
            ? EdgeInsets.only(top: 10.0)
            : EdgeInsets.only(top: 3.0),
        child: Text(_date(doc['timestamp']),
            textAlign: TextAlign.right, style: TextStyle(fontSize: 10.0)),
      );

  Widget _authorText(doc) => Container(
        margin: EdgeInsets.only(bottom: 5.0),
        child: doc['id'] == curUser.id
            ? SizedBox()
            : Text(
                doc['author'].split(' ')[0],
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.0),
              ),
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
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
                    return Text('Error: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    default:
                      return ListView(
                        controller: _scrollController,
                        children: snapshot.data.documents
                            .map((DocumentSnapshot document) {
                          return Container(
                              child: Row(
                            mainAxisAlignment: document['id'] == curUser.id
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () => print('User'),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: document['id'] == curUser.id
                                      ? SizedBox()
                                      : CircleAvatar(
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  document['img']),
                                        ),
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
                                    _authorText(document),
                                    _messageContent(document),
                                    _timeStamp(document),
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
            SizedBox(
              height: 7.0,
            ),
            isUploading
                ? SizedBox(
                    height: 7.0,
                    child: Text('Uploading ${progress.toStringAsFixed(2)}%'),
                  )
                : SizedBox(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.photo_library),
                  onPressed: () => _pickAndUploadImage(1),
                  tooltip: 'Gallery',
                ),
                IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: () => _pickAndUploadImage(0),
                  tooltip: 'Camera',
                ),
                Container(
                  child: Expanded(
                    child: Form(
                      key: _formKey,
                      // This thing goes to the bottom
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.0, right: 10.0),
                        child: Material(
                          color: Colors.grey[600],
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(25.0),
                          child: TextFormField(
                            validator: (String text) {
                              if (text.isEmpty) {
                                return;
                              }
                            },
                            controller: _msgController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 12.0),
                                hintText: 'Type message here...',
                                hintStyle: TextStyle(color: Colors.white70)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                FloatingActionButton(
                  mini: true,
                  tooltip: 'Send',
                  backgroundColor: Colors.blue,
                  child: Center(
                      child: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20.0,
                  )),
                  onPressed: () {
                    if (_formKey.currentState.validate() &&
                        _msgController.text.trim().length > 0) {
                      _sendNewMsg(
                          _msgController.text.trimRight().trimLeft(), false);
                    }
                  },
                ),
                SizedBox(
                  width: 5.0,
                )
              ],
            ),
            SizedBox(
              height: 10.0,
            )
          ],
        ),
      ),
      theme: ThemeData.dark(),
    );
  }

  Widget _buildDeleteDialog(BuildContext context, String docID) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Text('Delete this message?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              'This will delete message permanently.\nYou won\'t ever be able to recover it later')
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            _deleteMsg(docID);
            Navigator.of(context).pop();
          },
          child: Text('Sure! Do it.'),
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Oops! No.'),
        ),
      ],
    );
  }
}
