
class Scooter {
  final String id;
  String location;
  String stationid;
  String status;
  int batteryLevel;
  bool isBooked;
  bool isAvailable;

  Scooter({
    this.stationid = "1",
    this.id = "1234",
    this.location = "M4",
    this.status = "availble",
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