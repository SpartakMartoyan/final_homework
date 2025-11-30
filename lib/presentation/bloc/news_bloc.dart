import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/article.dart';
import '../../domain/usecases/get_top_headlines.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetTopHeadlines getTopHeadlines;

  List<Article> _originalList = [];

  NewsBloc({required this.getTopHeadlines}) : super(NewsInitial()) {
    on<GetNewsEvent>((event, emit) async {

      if (state is NewsLoaded) {
        if (event.query == null || event.query!.isEmpty) {
          _originalList = (state as NewsLoaded).articles;
        }
      }

      emit(NewsLoading());

      try {
        final articles = await getTopHeadlines(
          category: event.category,
          query: event.query,
        );

        if (event.query == null || event.query!.isEmpty) {
          _originalList = articles;
        }

        if (articles.isEmpty) {
          emit(const NewsError("No Results Found")); 
        } else {
          emit(NewsLoaded(articles));
        }
      } catch (e) {

        if (event.query != null && event.query!.isNotEmpty && _originalList.isNotEmpty) {
          final query = event.query!.toLowerCase();
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
          emit(const NewsError("Failed to fetch news. Check connection."));
        }
      }
    });
  }
}
