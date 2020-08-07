import 'package:PlayMusic/albums.dart';
import 'package:PlayMusic/allSongs.dart';
import 'package:PlayMusic/artists.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  var fabIcon = "Songs";
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            fabIcon = "Songs";
            break;
          case 1:
            fabIcon = "Artists";
            break;
          case 2:
            fabIcon = "Albums";
            break;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Play Music"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          tabs: <Widget>[
            new Tab(
              text: "Songs",
            ),
            new Tab(text: "Artists"),
            new Tab(
              text: "Albums",
            ),
          ],
        ),
      ),
      body: new TabBarView(
          controller: _tabController,
          children: <Widget>[AllSongs(), Artists(), Albums()]),
    );
  }
}
