const baseUrl = "http://172.31.144.1:8085";
const apiV1Prefix= "/api/v1";
const requestUrl= "$baseUrl$apiV1Prefix";

const bearerPrefix='Bearer '; //-single space is compulsory

enum Gender{
  male("Male"),
  female("Female"),
  other("Other");

  final String _value;
  const Gender(this._value);

  String get value => _value;
}


enum ComplaintPriority{
  low("LOW"),
  medium("MEDIUM"),
  high("HIGH");

  final String _value;
  const ComplaintPriority(this._value);

  String get value => _value;
}
