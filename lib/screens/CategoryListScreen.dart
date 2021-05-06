import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class Category {
  String name;
  String slug;
  IconData icon;

  Category({
    required this.name,
    required this.slug,
    this.icon = Icons.question_answer,
  });
}

class CategoryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CategoryListWidget();
  }
}

class CategoryListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildHeader(context),
      _buildButtons(context),
      _buildSomeStreams(context)
    ]);
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  "Next-Gen Live Streaming!",
                  style: Theme.of(context).textTheme.headline4,
                  // style: TextStyle(fontSize: 20),
                  maxLines: 1,
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: AutoSizeText(
                    "The first live streaming platform built around truly real time interactivity. Our streams are warp speed, our chat is blazing, and our community is thriving.",
                    style: Theme.of(context).textTheme.subtitle1),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              buildButton(
                  context,
                  Category(
                      name: "Gaming",
                      slug: "gaming",
                      icon: Icons.sports_esports)),
              buildButton(
                  context,
                  Category(
                    name: "Art",
                    slug: "art",
                    icon: Icons.color_lens,
                  )),
            ],
          ),
          Row(
            children: [
              buildButton(
                  context,
                  Category(
                    name: "Music",
                    slug: "music",
                    icon: Icons.music_note,
                  )),
              buildButton(
                  context,
                  Category(
                    name: "Tech",
                    slug: "tech",
                    icon: Icons.memory,
                  )),
            ],
          ),
          Row(
            children: [
              buildButton(
                  context,
                  Category(
                    name: "IRL",
                    slug: "irl",
                    icon: Icons.photo_camera,
                  )),
              buildButton(
                  context,
                  Category(
                    name: "Education",
                    slug: "education",
                    icon: Icons.school,
                  )),
            ],
          )
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, Category category) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(
            context,
            '/channels',
            arguments: category.slug,
          ),
          child: Column(
            children: [
              Icon(
                category.icon,
                color: Colors.blue,
                size: 50,
              ),
              Text(category.name)
            ],
          ),
          style: ElevatedButton.styleFrom(
            side: BorderSide(width: 1, color: Colors.grey),
            textStyle: Theme.of(context).textTheme.headline6,
            primary: Colors.transparent,
            padding: EdgeInsets.all(20),
          ),
        ),
      ),
    );
  }

  Widget _buildSomeStreams(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  "Explore Live Streams",
                  style: Theme.of(context).textTheme.headline4,
                  // style: TextStyle(fontSize: 20),
                  maxLines: 1,
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: AutoSizeText(
                    "Experience real time interaction by visiting some of these selected streams!",
                    style: Theme.of(context).textTheme.subtitle1),
              )
            ],
          ),
        ],
      ),
    );
  }
}
