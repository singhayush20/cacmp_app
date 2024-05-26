
import 'dart:convert';

List<Article> articlesFromJson(List<dynamic> list) {
 return List<Article>.from(list.map((x) {
   return Article.fromJson(x);
 }));
}

String articlesToJson(List<Article> data) {
  final dyn = List<dynamic>.from(data.map((x) => x.toJson()));
  return json.encode(dyn);
}

class Article {
  String articleToken;
  String title;
  String slug;
  String publishStatus;
  String publishDate;
  String departmentName;
  List<ArticleMedia> articleMedia;

  Article({
    required this.articleToken,
    required this.title,
    required this.slug,
    required this.publishStatus,
    required this.publishDate,
    required this.departmentName,
    required this.articleMedia,
  });

  factory Article.fromJson(Map<String, dynamic> json) =>  Article(
    articleToken: json["articleToken"],
    title: json["title"],
    slug: json["slug"],
    publishStatus: json["publishStatus"],
    publishDate: json["publishDate"],
    departmentName: json["departmentName"],
    articleMedia:  List<ArticleMedia>.from(json["articleMedia"].map((x) => ArticleMedia.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "articleToken": articleToken,
    "title": title,
    "slug": slug,
    "publishStatus": publishStatus,
    "publishDate": publishDate,
    "departmentName": departmentName,
    "articleMedia":  List<dynamic>.from(articleMedia.map((x) => x.toJson())),
  };
}

class ArticleMedia {
  String mediaToken;
  String mediaType;
  String format;
  String fileName;
  String url;

  ArticleMedia({
    required this.mediaToken,
    required this.mediaType,
    required this.format,
    required this.fileName,
    required this.url,
  });

  factory ArticleMedia.fromJson(Map<String, dynamic> json) => ArticleMedia(
    mediaToken: json["mediaToken"],
    mediaType: json["mediaType"],
    format: json["format"],
    fileName: json["fileName"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "mediaToken": mediaToken,
    "mediaType": mediaType,
    "format": format,
    "fileName": fileName,
    "url": url,
  };
}
