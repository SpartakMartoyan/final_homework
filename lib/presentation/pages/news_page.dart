import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import 'article_detail_page.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  // List of categories required by the assignment
  final List<String> _categories = [
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper to trigger the BLoC event
  void _fetchNews() {
    context.read<NewsBloc>().add(
      GetNewsEvent(
        query: _searchController.text,
        category: _selectedCategory,
      ),
    );
  }

  // Show Filter Dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _categories.map((category) {
                return ListTile(
                  title: Text(category.toUpperCase()),
                  leading: Radio<String>(
                    value: category,
                    groupValue: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      Navigator.pop(context); // Close dialog
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Clear filter
                setState(() {
                  _selectedCategory = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Clear Filter'),
            ),
            TextButton(
              onPressed: () {
                _fetchNews(); // Apply logic (The requirement says "Apply" button triggers request)
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    ).then((_) {
      // After dialog closes, fetch news with new filter
      _fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _fetchNews(); // Clear search and reload
                        },
                      ),
                    ),
                    onSubmitted: (value) => _fetchNews(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _fetchNews,
                ),
              ],
            ),
          ),

          // --- Show selected category if any ---
          if (_selectedCategory != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text('Category: $_selectedCategory'),
                  onDeleted: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                    _fetchNews();
                  },
                ),
              ),
            ),

          // --- News List with Pull to Refresh ---
          Expanded(
            child: BlocBuilder<NewsBloc, NewsState>(
              builder: (context, state) {
                if (state is NewsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is NewsError) {
                  return Center(child: Text(state.message));
                } else if (state is NewsLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      _fetchNews();
                    },
                    child: ListView.builder(
                      itemCount: state.articles.length,
                      itemBuilder: (context, index) {
                        final article = state.articles[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: () {
                              // Navigate to details page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleDetailPage(article: article),
                                ),
                              );
                            },
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
                    ),
                  );
                }
                return const Center(child: Text('Start by searching or loading news...'));
              },
            ),
          ),
        ],
      ),
    );
  }
}