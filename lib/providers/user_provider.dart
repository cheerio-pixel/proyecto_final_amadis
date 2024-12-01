import 'package:draft1/models/user.dart';
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;

  Future<void> fetchUserInfo() async {
    try {
      // Implement your user info fetch logic here using ApiService
      // For now, we'll use mock data
      _user = User(
        id: 1,
        nombre: 'John',
        apellido: 'Doe',
        username: 'johndoe',
        email: 'john@example.com',
      );
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}