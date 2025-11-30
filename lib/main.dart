import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'data/datasources/remote_data_source.dart';
import 'data/repositories/news_repository_impl.dart';
import 'domain/usecases/get_top_headlines.dart';
import 'presentation/bloc/news_bloc.dart';
import 'presentation/bloc/news_event.dart';
import 'presentation/pages/news_page.dart'; //not created yet

void main() {
  final http.Client client = http.Client();
  final remoteDataSource = RemoteDataSourceImpl(client: client);
  final repository = NewsRepositoryImpl(remoteDataSource: remoteDataSource);
  final getTopHeadlines = GetTopHeadlines(repository);

  runApp(MyApp(getTopHeadlines: getTopHeadlines));
}

class MyApp extends StatelessWidget {
  final GetTopHeadlines getTopHeadlines;

  const MyApp({super.key, required this.getTopHeadlines});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      
      home: BlocProvider(
        create: (context) => NewsBloc(getTopHeadlines: getTopHeadlines)
          ..add(GetNewsEvent()),
        child: const NewsPage(),
      ),
    );
  }
}
