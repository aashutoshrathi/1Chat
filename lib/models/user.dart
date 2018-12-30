import 'package:firebase_auth/firebase_auth.dart';

class User {
  final String id;
  final String name;
  final String imgURL;

  const User(this.id, this.name, this.imgURL)
      : assert(id != null),
        assert(name != null),
        assert(imgURL != null);

  User.fromFirebaseUser(FirebaseUser user)
      : assert(user.uid != null),
        id = user.uid,
        name = user.displayName,
        imgURL = user.photoUrl;

  User.fromMap(Map<dynamic, dynamic> map)
      : assert(map['id'] != null),
        id = map['id'],
        name = map['name'],
        imgURL = map['imgURL'];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> _userMap = Map();
    _userMap['id'] = this.id;
    _userMap['name'] = this.name;
    _userMap['imgURL'] = this.imgURL;
    return _userMap;
  }

  @override
  String toString() => "User<$id | $name>";
}
