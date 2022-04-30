import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {
  static const _keyUserId = 'id';
  static const _keyPhotoUrl = 'photoUrl';
  static const _keyDisplayName = 'displayName';
  static const _keyTimeStamp = 'timestamp';
  static const _keyIsAdmin = 'isAdmin';

//TO set shared pereference for this field (id) and store the string to phone
  static Future setId(String id) async {
    SharedPreferences preferences =
        await SharedPreferences.getInstance(); //Instantiate SharedPref
    return preferences.setString(_keyUserId, id); //Store string data to phone
  }



  static Future setPhotoUrl(String photoUrl) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(_keyPhotoUrl, photoUrl);
  }

  static Future setDisplayName(String displayName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(_keyDisplayName, displayName);
  }

  static Future setIsAdmin(bool isAdmin) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setBool(_keyIsAdmin, isAdmin);
  }


  static Future setTimestamp(DateTime timestampp) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final timestamp = timestampp.toIso8601String();
    return preferences.setString(_keyTimeStamp, timestamp);
  }


//TO get String Id stored
  Future<String?> getId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_keyUserId);
  }


  Future<String?> getPhotoUrl() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_keyPhotoUrl);
  }

  Future<String?> getDisplayName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_keyDisplayName);
  }

  Future<bool?> getIsAdmin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_keyIsAdmin);
  }


  Future<String?> getTimestamp() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_keyTimeStamp);
  }

}
