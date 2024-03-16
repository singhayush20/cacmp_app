

import 'package:meta/meta.dart';
import 'dart:convert';

List<Poll> pollFromJson(List<dynamic> str) {
  return List<Poll>.from(str.map((x) {
    return Poll.fromJson(x);
  }));
}

String pollToJson(List<Poll> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Poll {
  String description;
  String deptToken;
  String departmentName;
  String pollToken;
  DateTime liveOn;
  String subject;

  Poll({
    required this.description,
    required this.deptToken,
    required this.departmentName,
    required this.pollToken,
    required this.liveOn,
    required this.subject,
  });

  factory Poll.fromJson(Map<String, dynamic> json) => Poll(
    description: json["description"],
    deptToken: json["deptToken"],
    departmentName: json["departmentName"],
    pollToken: json["pollToken"],
    liveOn: DateTime.parse(json["liveOn"]),
    subject: json["subject"],
  );

  Map<String, dynamic> toJson() => {
    "description": description,
    "deptToken": deptToken,
    "departmentName": departmentName,
    "pollToken": pollToken,
    "liveOn": liveOn.toIso8601String(),
    "subject": subject,
  };
}
