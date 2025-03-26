import 'package:shared_preferences/shared_preferences.dart';

class CusAuth {
  Future<void> signOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Deletes all the shared preferences
  }
}
