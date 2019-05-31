import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hacker_news_app/models/hackernews.dart';

class HomeScreenState with ChangeNotifier {
  static List<dynamic> _topStoryIds = [];
  static List<dynamic> _newStoryIds = [];
  var _cachedArticles = HashMap<int, HackerNews>();

  final String baseUrl = "https://hacker-news.firebaseio.com/v0/";

  bool _isNewStoriesLoading = true;
  bool _isTopStoriesLoading = true;

  ArticleType articleType = ArticleType.NewStories;

  int _bottomNavigationBarIndex = 0;

  HomeScreenState._() {
    _updateArticles(ArticleType.NewStories).then((_) {});
  }

  Future<List<dynamic>> initializeArticles(ArticleType type) async {
    String partUrl = type == ArticleType.NewStories ? "new" : "top";
    String url = "$baseUrl${partUrl}stories.json";
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw HackerNewsApiError("Story type $type Couldn't be fetched");
    }
    return jsonDecode(response.body);
  }

  List<HackerNews> get articles {
    if (articleType == ArticleType.NewStories) return _newArticles;
    if (articleType == ArticleType.TopStories) return _topArticles;
    return null;
  }

  bool get isLoading {
    if (articleType == ArticleType.NewStories) return _isNewStoriesLoading;
    if (articleType == ArticleType.TopStories) return _isTopStoriesLoading;
    return false;
  }

  int get bottomNavigationBarIndex => _bottomNavigationBarIndex;

  List<HackerNews> get allArticles  {
    List<HackerNews> _allArticles = new List<HackerNews>();
    _allArticles.addAll(_newArticles);
    _allArticles.addAll(_topArticles);
    return _allArticles ;
  }

  void changeArticleType(int index) {
    if (index == 0) {
      articleType = ArticleType.NewStories;
      _bottomNavigationBarIndex = 0;
      _updateArticles(ArticleType.NewStories);
    }
    if (index == 1) {
      articleType = ArticleType.TopStories;
      _bottomNavigationBarIndex = 1;
      _updateArticles(ArticleType.TopStories);
    }
    notifyListeners();
  }

  factory HomeScreenState() {
    return HomeScreenState._();
  }

  List<HackerNews> _topArticles = [];
  List<HackerNews> _newArticles = [];

  Future<Null> _updateArticles(ArticleType type) async {
    bool needToFetch = false;
    if ((type == ArticleType.NewStories && _newArticles.isEmpty) ||
        (type == ArticleType.TopStories && _topArticles.isEmpty))
      needToFetch = true;

    if (needToFetch) {
      var storyIds = await initializeArticles(type);
      type == ArticleType.NewStories
          ? _newStoryIds = storyIds
          : _topStoryIds = storyIds;

      for (int id in storyIds) {
        HackerNews newArticle = await _getArticle(id);
        type == ArticleType.NewStories
            ? _newArticles.add(newArticle)
            : _topArticles.add(newArticle);
        //todo : create a separate notifier for both new storis and top stories
        if (storyIds.indexOf(id) > 5) notifyListeners();
        if (storyIds.indexOf(id) > 10) break;
      }
      type == ArticleType.NewStories
          ? _isNewStoriesLoading = false
          : _isTopStoriesLoading = false;
      notifyListeners();
    }
  }

  Future<HackerNews> _getArticle(var id) async {
    if (!_cachedArticles.containsKey(id)) {
      final url = "${baseUrl}item/$id.json";
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _cachedArticles[id] = parseHackerNews(response.body);
      } else {
        throw HackerNewsApiError("Article $id Couldn't Be Fetched");
      }
    }
    return _cachedArticles[id];
  }
}

enum ArticleType { TopStories, NewStories }

class HackerNewsApiError extends Error {
  final String message;

  HackerNewsApiError(this.message);
}
