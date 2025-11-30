import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/remote_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  final RemoteDataSource remoteDataSource;

  NewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Article>> getTopHeadlines() async {
    try {
      final articleModels = await remoteDataSource.getTopHeadlines();
      return articleModels;
    } catch (e) {
      // For now, we just rethrow the error.
      rethrow;
    }
  }
}
