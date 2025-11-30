import '../entities/article.dart';

abstract class NewsRepository {
  Future<List<Article>> getTopHeadlines({String? category, String? query});
}