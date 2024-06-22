import 'package:web_admin/views/classes/Ride.dart';

class User {
  String _name;
  String _email;
  String _phoneNumber;
  String _imagePath;
  double _balance;
  String _status;
  List<Ride> _rides;

  User({
    required String name,
    required String email,
    required String phoneNumber,
    required String imagePath,
    double balance = 100.00,
    String status = 'active',
    List<Ride>? rides,
  })  : _name = name,
        _email = email,
        _phoneNumber = phoneNumber, 
        _imagePath = imagePath,
        _balance = balance,
        _status = status,
        _rides = rides ?? [];

  // Getters
  String get name => _name;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String get imagePath => _imagePath;
  double get balance => _balance;
  String get status => _status;
  List<Ride> get rides => _rides;

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

  set balance(double value) {
    _balance = value;
  }

  set status(String value) {
    _status = value;
  }

  set rides(List<Ride> value) {
    _rides = value;
  }
}
