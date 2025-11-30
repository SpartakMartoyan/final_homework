import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

abstract class RemoteDataSource {
  Future<List<ArticleModel>> getTopHeadlines();
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final http.Client client;

  RemoteDataSourceImpl({required this.client});

  // TODO: Replace with your actual API Key from newsapi.org
  final String apiKey = '7b703952653347b48b8fabb49b8c5263';
  final String baseUrl = 'https://newsapi.org/v2';

  @override
  Future<List<ArticleModel>> getTopHeadlines() async {
    final response = await client.get(
      Uri.parse('$baseUrl/top-headlines?country=us&apiKey=$apiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      final List<dynamic> articlesJson = jsonBody['articles'];

      return articlesJson
          .map((json) => ArticleModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}