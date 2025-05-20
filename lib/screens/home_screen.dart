import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../model/item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // カテゴリマップ
  Map<String, String> categoryMap = {
    'domestic': '国内',
    'world': '国際',
    'business': '経済',
    'entertainment': 'エンタメ',
    'sports': 'スポーツ',
    'it': 'IT',
    'science': '科学',
    'life': 'ライフ',
    'local': '地域',
  };

  String selectedCategory = 'domestic';
  List<ItemModel> itemModelList = [];

  ///
  @override
  void initState() {
    super.initState();
    fetchNewsByCategory(selectedCategory);
  }

  ///
  Future<void> fetchNewsByCategory(String category) async {
    final response = await http.get(Uri.parse('https://news.yahoo.co.jp/rss/categories/$category.xml'));

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      setState(() {
        itemModelList =
            items.map((element) {
              // ignore: deprecated_member_use
              final title = element.findElements('title').single.text;
              // ignore: deprecated_member_use
              final link = element.findElements('link').single.text;

              // ignore: deprecated_member_use
              final pubDate = element.findElements('pubDate').single.text;
              // ignore: deprecated_member_use
              final image = element.findElements('image').single.text;
              // ignore: deprecated_member_use
              final description = element.findElements('description').single.text;

              return ItemModel(
                title: title,
                link: link,
                pubDate: pubDate,
                image: image,
                comments: '',
                description: description,
              );
            }).toList();
      });
    } else {
      throw Exception('Failed to load RSS feed');
    }
  }

  ///
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categoryMap.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('News Categories'),
          bottom: TabBar(
            isScrollable: true,
            tabs: categoryMap.entries.map((entry) => Tab(text: entry.value)).toList(),

            onTap: (index) {
              setState(() {
                selectedCategory = categoryMap.keys.toList()[index];
                fetchNewsByCategory(selectedCategory);
              });
            },
          ),
        ),
        body: TabBarView(
          children:
              categoryMap.keys.map((category) => NewsListView(category: category, newsItems: itemModelList)).toList(),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////

class NewsListView extends StatefulWidget {
  const NewsListView({super.key, required this.category, required this.newsItems});

  final String category;
  final List<ItemModel> newsItems;

  @override
  State<NewsListView> createState() => _NewsListViewState();
}

class _NewsListViewState extends State<NewsListView> {
  ///
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.newsItems.length,
      itemBuilder: (context, index) {
        final newsItem = widget.newsItems[index];
        return ListTile(
          title: Text(newsItem.title),
          subtitle: Text(newsItem.link),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailPage(newsItem: newsItem)));
          },
        );
      },
    );
  }
}

//////////////////////////////////////////////////////////////

class NewsDetailPage extends StatefulWidget {
  const NewsDetailPage({super.key, required this.newsItem});

  final ItemModel newsItem;

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.newsItem.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.newsItem.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Link: ${widget.newsItem.link}', style: TextStyle(fontSize: 16, color: Colors.blue)),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WebViewScreen(url: widget.newsItem.link)),
                  ),
              child: Text('Open in WebView'),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key, required this.url});

  final String url;

  @override
  // ignore: library_private_types_in_public_api
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late InAppWebViewController webViewController;

  late PullToRefreshController pullToRefreshController;

  double progress = 0;

  ///
  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(onRefresh: () async => webViewController.reload());
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WebView')),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              onWebViewCreated: (controller) => webViewController = controller,
              pullToRefreshController: pullToRefreshController,
              onLoadStart: (controller, url) => pullToRefreshController.beginRefreshing(),
              onLoadStop: (controller, url) async => pullToRefreshController.endRefreshing(),
              onProgressChanged: (controller, progressValue) => setState(() => progress = progressValue / 100),
            ),
          ),
        ],
      ),
    );
  }
}
