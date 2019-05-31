import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hacker_news_app/homepage_state.dart';
import 'package:hacker_news_app/models/hackernews.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _buildListItem(HackerNews hackerNews) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: ExpansionTile(
          title: Text(
            "${hackerNews.title}",
            style: TextStyle(fontSize: 25),
          ),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                    "${hackerNews.descendants != null ? hackerNews.descendants : 0} Comments"),
                IconButton(
                  icon: Icon(Icons.launch),
                  onPressed: () async {
                    if (await canLaunch(hackerNews.url)) {
                      launch(hackerNews.url);
                    }
                  },
                )
              ],
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Hacker News",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              fontFamily: 'Bangers',
            )),
        elevation: 0,
        centerTitle: true,
        leading: Provider.of<HomeScreenState>(context).isLoading
            ? Padding(
                padding: EdgeInsets.all(10), child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: LoadingIcon()),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ArticleSearch());
            },
          )
        ],
      ),
      body: Consumer<HomeScreenState>(
        builder: (context, state, _) {
          return ListView(
            children: state.articles
                .map((article) => _buildListItem(article))
                .toList(),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:
            Provider.of<HomeScreenState>(context).bottomNavigationBarIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.new_releases), title: Text("New Stories")),
          BottomNavigationBarItem(
              icon: Icon(Icons.star), title: Text("Top Stories"))
        ],
        onTap: (index) {
          Provider.of<HomeScreenState>(context).changeArticleType(index);
        },
        backgroundColor: Theme.of(context).primaryColor,
        fixedColor: Theme.of(context).accentColor,
        unselectedItemColor: Colors.black54,
      ),
    );
  }
}

class LoadingIcon extends StatefulWidget {
  @override
  _LoadingIconState createState() => _LoadingIconState();
}

class _LoadingIconState extends State<LoadingIcon>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return FadeTransition(
      child: Icon(
        FontAwesomeIcons.hackerNews,
        size: 40,
      ),
      opacity: _controller,
    );
  }
}

class ArticleSearch extends SearchDelegate<HackerNews> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return query.isNotEmpty
        ? [
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                query = '';
              },
            )
          ]
        : [Container()];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<HackerNews> _articleList = Provider.of<HomeScreenState>(context)
        .allArticles
        .where((article) => article.title.toLowerCase().contains(query))
        .toList();
    if (_articleList.isEmpty) {
      return Center(
        child: Text("No Data"),
      );
    }
    return ListView(
      children: _articleList
          .map((article) => ListTile(
                title: Text("${article.title}"),
                onTap: () async{
                 if(await canLaunch(article.url))  launch(article.url);
                },
              ))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<HackerNews> _articleList = Provider.of<HomeScreenState>(context)
        .allArticles
        .where((article) => article.title.toLowerCase().contains(query))
        .toList();
    if (_articleList.isEmpty) {
      return Center(
        child: Text("No Data"),
      );
    }
    return ListView(
      children: _articleList
          .map((article) => ListTile(
        title: Text("${article.title}"),
        onTap: () async{
          if(await canLaunch(article.url))  launch(article.url);
        },
      ))
          .toList(),
    );
  }
}
