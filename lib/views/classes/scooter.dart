
class Scooter {
  final String id;
  String location;
  String stationid;
  String status;
  int batteryLevel;
  bool isBooked;
  bool isAvailable;

  Scooter({
    this.stationid = "",
    this.id = "",
    this.location = "",
    this.status = "",
    this.batteryLevel = 80,
    this.isBooked = false,
    this.isAvailable = true,
  });


  void book() {
    if (isAvailable) {
      isBooked = true;
      isAvailable = false;
    }
  }

  void unbook() {
    if (isBooked) {
      isBooked = false;
      isAvailable = true;
    }
  }
}