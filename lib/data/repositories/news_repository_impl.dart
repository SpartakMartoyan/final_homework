import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/remote_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  final RemoteDataSource remoteDataSource;

  NewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Article>> getTopHeadlines({String? category, String? query}) async {
    try {
      return await remoteDataSource.getTopHeadlines(category: category, query: query);
    } catch (e) {
      rethrow;
    }
  }
}