import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_profile_service.dart';

class ClearAllData {
  static Future<void> clearEverything() async {
    try {
      // 1. Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // 2. Clear SharedPreferences (all local storage)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // 3. Clear UserProfileService cache
      final profileService = UserProfileService();
      profileService.clearCache();
      
      print('✅ All data cleared successfully!');
      print('   - Firebase auth signed out');
      print('   - SharedPreferences cleared');
      print('   - Profile cache cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }
}
