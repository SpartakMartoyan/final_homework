import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object> get props => [];
}

class GetNewsEvent extends NewsEvent {
  final String? category;
  final String? query;

  const GetNewsEvent({this.category, this.query});

  @override
  List<Object> get props => [category ?? '', query ?? ''];
}