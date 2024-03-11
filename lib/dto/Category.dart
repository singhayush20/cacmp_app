// To parse this JSON data, do
//
//     final category = categoryFromJson(jsonString);

import 'dart:convert';
import 'dart:developer';

List<Category> categoriesFromJson(List<dynamic> list) {
  return List<Category>.from(list.map((x) {
    log('category: $x');
    return Category.fromJson(x);
  }));
}

String categoryToJson(List<Category> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Category {
  String categoryToken;
  String categoryName;
  String categoryDescription;

  Category({
    required this.categoryToken,
    required this.categoryName,
    required this.categoryDescription,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        categoryToken: json["categoryToken"],
        categoryName: json["categoryName"],
        categoryDescription: json["categoryDescription"],
      );

  Map<String, dynamic> toJson() => {
        "categoryToken": categoryToken,
        "categoryName": categoryName,
        "categoryDescription": categoryDescription,
      };
}
