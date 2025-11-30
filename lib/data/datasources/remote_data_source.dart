import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

abstract class RemoteDataSource {
  // We added category and query here
  Future<List<ArticleModel>> getTopHeadlines({String? category, String? query});
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final http.Client client;

  RemoteDataSourceImpl({required this.client});

  // TODO: Put your API Key here
  final String apiKey = '7b703952653347b48b8fabb49b8c5263';
  final String baseUrl = 'https://newsapi.org/v2';

  @override
  Future<List<ArticleModel>> getTopHeadlines({String? category, String? query}) async {
    // 1. Base URL
    String url = '$baseUrl/top-headlines?country=us&apiKey=$apiKey';

    // 2. Add Category if it exists
    if (category != null && category.isNotEmpty) {
      url += '&category=$category';
    }

    // 3. Add Search Query if it exists
    if (query != null && query.isNotEmpty) {
      url += '&q=$query';
    }

    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      final List<dynamic> articlesJson = jsonBody['articles'];
      return articlesJson.map((json) => ArticleModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}