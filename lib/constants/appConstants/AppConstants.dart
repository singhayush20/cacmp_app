const baseUrl = "https://840d-138-199-22-99.ngrok-free.app";
const apiV1Prefix = "/api/v1";
const requestUrl = "$baseUrl$apiV1Prefix";

const bearerPrefix = 'Bearer '; //-single space is compulsory

enum Gender {
  male("Male"),
  female("Female"),
  other("Other");

  final String _value;

  const Gender(this._value);

  String get value => _value;
}

enum ComplaintPriority {
  low("LOW"),
  medium("MEDIUM"),
  high("HIGH");

  final String _value;

  const ComplaintPriority(this._value);

  String get value => _value;
}

enum ComplaintStatus {
  open("OPEN"),
  reviewed("REVIEWED"),
  closed("CLOSED");

  final String _value;

  const ComplaintStatus(this._value);

  String get value => _value;
}

enum AlertInputType {
  text("TEXT"),
  document("DOCUMENT");

  final String _value;

  const AlertInputType(this._value);

  String get value => _value;
}


enum MediaType{
  video("VIDEO"),
  image("IMAGE");

  final String _value;

  const MediaType(this._value);
  String get value => _value;
}

bool isValidPhoneNumber(String value) {
  if (value == null) {
    return false;
  }
  return double.tryParse(value) != null && value.trim().length == 10;
}

bool isValidOTP(String? value) {
  if (value == null) {
    return false;
  }
  return double.tryParse(value) != null;
}
