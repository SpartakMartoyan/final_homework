import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_state.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Headlines'),
        centerTitle: true,
      ),
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {

          // 1. Show Loading Spinner
          if (state is NewsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Show Error Message
          else if (state is NewsError) {
            return Center(child: Text(state.message));
          }

          // 3. Show the List of News
          else if (state is NewsLoaded) {
            return ListView.builder(
              itemCount: state.articles.length,
              itemBuilder: (context, index) {
                final article = state.articles[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: article.urlToImage != null
                        ? SizedBox(
                      width: 100,
                      child: CachedNetworkImage(
                        imageUrl: article.urlToImage!,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    )
                        : const SizedBox(width: 100, child: Icon(Icons.image_not_supported)),
                    title: Text(
                      article.title ?? 'No Title',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      article.sourceName ?? 'Unknown Source',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            );
          }

          // 4. Default State
          return const Center(child: Text('Start by loading news...'));
        },
      ),
    );
  }
}