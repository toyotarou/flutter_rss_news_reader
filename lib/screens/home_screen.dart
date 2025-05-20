import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rss_news_reader/extensions/extensions.dart';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../model/item.dart';
import 'components/web_view_alert.dart';
import 'parts/news_dialog.dart';

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

        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: context.screenSize.height / 10),

          child: Container(
            padding: EdgeInsets.all(10),
            // ignore: deprecated_member_use
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  child: CachedNetworkImage(
                    imageUrl: newsItem.image,
                    placeholder: (BuildContext context, String url) => Image.asset('assets/images/no_image.png'),
                    errorWidget: (BuildContext context, String url, Object error) => const Icon(Icons.error),
                  ),
                ),
                SizedBox(width: 20),

                Expanded(
                  child: DefaultTextStyle(
                    style: TextStyle(fontSize: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(newsItem.title, maxLines: 3, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 5),
                        Text(
                          newsItem.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 20),

                GestureDetector(
                  onTap: () => NewsDialog(context: context, widget: WebViewAlert(url: newsItem.link)),
                  child: Icon(Icons.call_made, color: Colors.white.withValues(alpha: 0.4)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
