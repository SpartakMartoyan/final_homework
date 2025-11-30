import '../entities/article.dart';
import '../repositories/news_repository.dart';

class GetTopHeadlines {
  final NewsRepository repository;

  GetTopHeadlines(this.repository);

  // This function makes the class callable like a function
  Future<List<Article>> call() async {
    return await repository.getTopHeadlines();
  }
}