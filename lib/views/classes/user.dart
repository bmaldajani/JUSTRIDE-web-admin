class User {
  String _name;
  String _email;
  String _phoneNumber;
  String _imagePath;

  User({
    required String name,
    required String email,
    required String phoneNumber,
    required String imagePath,
  })  : _name = name,
        _email = email,
        _phoneNumber = phoneNumber,
        _imagePath = imagePath;

  // Getters
  String get name => _name;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String get imagePath => _imagePath;

  // Setters
  set name(String value) {
    _name = value;
  }

  set email(String value) {
    _email = value;
  }

  set phoneNumber(String value) {
    _phoneNumber = value;
  }

  set imagePath(String value) {
    _imagePath = value;
  }
}
