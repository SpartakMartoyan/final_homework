import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/article.dart';
import '../../domain/usecases/get_top_headlines.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetTopHeadlines getTopHeadlines;

  // We keep a local copy of the full list for offline searching
  List<Article> _originalList = [];

  NewsBloc({required this.getTopHeadlines}) : super(NewsInitial()) {
    on<GetNewsEvent>((event, emit) async {

      // 1. If we currently have data, keep it in memory before we switch to 'Loading'
      if (state is NewsLoaded) {
        // Only update our "master list" if we aren't already searching
        // This ensures we always search against the full list, not a sub-list
        if (event.query == null || event.query!.isEmpty) {
          _originalList = (state as NewsLoaded).articles;
        }
      }

      emit(NewsLoading());

      try {
        // 2. Try to fetch from API
        final articles = await getTopHeadlines(
          category: event.category,
          query: event.query,
        );

        // If successful, update our local master list (only if not searching)
        if (event.query == null || event.query!.isEmpty) {
          _originalList = articles;
        }

        if (articles.isEmpty) {
          emit(const NewsError("No Results Found")); //
        } else {
          emit(NewsLoaded(articles));
        }
      } catch (e) {
        // 3. OFFLINE FALLBACK
        // If API fails, check if we have a query and local data
        if (event.query != null && event.query!.isNotEmpty && _originalList.isNotEmpty) {
          final query = event.query!.toLowerCase();

          // Filter locally
          final localResults = _originalList.where((article) {
            final title = article.title?.toLowerCase() ?? '';
            return title.contains(query);
          }).toList();

          if (localResults.isEmpty) {
            emit(const NewsError("No Results Found"));
          } else {
            emit(NewsLoaded(localResults));
          }
        } else {
          // If we can't search locally, show the actual error
          emit(const NewsError("Failed to fetch news. Check connection."));
        }
      }
    });
  }
}