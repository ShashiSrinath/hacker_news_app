import 'package:flutter/material.dart';
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
        key: Key(hackerNews.title),
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
                Text("${hackerNews.type}"),
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

    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              "Hacker News",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            backgroundColor: Colors.black54,
            centerTitle: true,
            leading: Provider.of<HomeScreenState>(context).isLoading
                ? Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator())
                : Container(),
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
          ),
        ));
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
    _controller.forward().then((f) => _controller.reverse());
    return FadeTransition(
      child: Icon(FontAwesomeIcons.hackerNews),
      opacity: _controller,
    );
  }
}
