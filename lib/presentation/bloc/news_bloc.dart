import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_top_headlines.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetTopHeadlines getTopHeadlines;

  NewsBloc({required this.getTopHeadlines}) : super(NewsInitial()) {
    // When "GetNewsEvent" happens, execute this logic:
    on<GetNewsEvent>((event, emit) async {
      emit(NewsLoading()); // 1. Tell UI to show loading spinner

      try {
        final articles = await getTopHeadlines(); // 2. Fetch data
        emit(NewsLoaded(articles)); // 3. Tell UI to show data
      } catch (e) {
        emit(NewsError("Failed to fetch news")); // 4. Tell UI to show error
      }
    });
  }
}