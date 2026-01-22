class UserDatabase {
  static final Map<String, String> _users = {
    'admin@gmail.com': 'admin1234',
  };

  static bool registerUser(String email, String password) {
    if (_users.containsKey(email)) {
      return false;
    }
    _users[email] = password;
    return true;
  }

  static bool loginUser(String email, String password) {
    return _users.containsKey(email) && _users[email] == password;
  }

  static Map<String, String> getAllUsers() {
    return Map.from(_users);
  }
}