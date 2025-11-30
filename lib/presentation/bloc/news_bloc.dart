import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_top_headlines.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetTopHeadlines getTopHeadlines;

  NewsBloc({required this.getTopHeadlines}) : super(NewsInitial()) {
    on<GetNewsEvent>((event, emit) async {
      emit(NewsLoading()); 

      try {
        final articles = await getTopHeadlines(); 
        emit(NewsLoaded(articles)); 
      } catch (e) {
        emit(NewsError("Failed to fetch news")); 
      }
    });
  }
}
