import 'dart:convert';

List<Complaint> complaintsFromJson(List<dynamic> str) {
  return List<Complaint>.from(str.map((x) {
    return Complaint.fromJson(x);
  }));
}

String complaintToJson(List<Complaint> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Complaint {
  String complaintCategory;
  String complaintToken;
  String complaintStatus;
  String complaintDescription;
  String complaintSubject;
  String complaintPriority;

  Complaint({
    required this.complaintCategory,
    required this.complaintToken,
    required this.complaintStatus,
    required this.complaintDescription,
    required this.complaintSubject,
    required this.complaintPriority,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) => Complaint(
    complaintCategory: json["complaintCategory"],
    complaintToken: json["complaintToken"],
    complaintStatus: json["complaintStatus"],
    complaintDescription: json["complaintDescription"],
    complaintSubject: json["complaintSubject"],
    complaintPriority: json["complaintPriority"],
  );

  Map<String, dynamic> toJson() => {
    "complaintCategory": complaintCategory,
    "complaintToken": complaintToken,
    "complaintStatus": complaintStatus,
    "complaintDescription": complaintDescription,
    "complaintSubject": complaintSubject,
    "complaintPriority": complaintPriority,
  };
}
