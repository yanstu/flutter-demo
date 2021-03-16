import 'dart:math';
import 'package:demo/util/config.dart';
import 'package:demo/widget/load.dart';
import '../main.dart';
import 'package:demo/bean/Stars.dart';
import 'package:demo/bean/UserRecord.dart';
import 'package:demo/util/SharedPreferenceUtil.dart';
import 'package:demo/util/tool.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'dart:convert' show json;
import 'package:flutter/services.dart';

class Choose extends StatefulWidget {
  @override
  _ChooseState createState() => _ChooseState();
}

class _ChooseState extends State<Choose> with SingleTickerProviderStateMixin {
  bool get wantKeepAlive => true;
  ScrollController _scrollController = new ScrollController();
  var names = new List();
  List hots = new List();
  var jsonRes;
  String searchValue = "";
  var pageNo = 1;
  var type = "全部";
  DateTime lastPopTime;
  var _saved;
  TabController _tabController;
  final dio = new Dio();
  bool haveData = true;
  final List<Tab> myTabs = <Tab>[
    new Tab(text: '全部'),
    new Tab(text: '安卓'),
    new Tab(text: '苹果'),
    new Tab(text: '电脑'),
    new Tab(text: '压缩包'),
    new Tab(text: '文档'),
    new Tab(text: '其他'),
  ];

  void _getMoreData() async {
    String uid =
        await SharedPreferenceUtil.getString(SharedPreferenceUtil.KEY_ACCOUNT);
    String url = (Config.url +
        "/api/resource?page=$pageNo" +
        "&resid=" +
        Tool.get(uid) +
        "&filename=" +
        searchValue +
        "&type=" +
        type); //
    print(url);
    final response = await dio.get(url);
    jsonRes = json.decode(Tool.decode(response.toString()));
    setState(() {
      for (var dataItem in jsonRes['data']) {
        names.add(dataItem);
      }
    });

    if (jsonRes['next'] == "noexist") {
      setState(() {
        haveData = false;
      });
    } else {
      setState(() {
        pageNo++;
        haveData = true;
      });
    }
  }

  void _getHotSearch() async {
    String url = (Config.url + "/api/getHotsearch");
    final response = await dio.get(url);
    jsonRes = json.decode(Tool.decode(response.toString()));
    setState(() {
      for (var dataItem in jsonRes) {
        hots.add(dataItem);
      }
    });
  }

  Future<dynamic> _onRefresh() async {
    names.clear();
    String uid =
        await SharedPreferenceUtil.getString(SharedPreferenceUtil.KEY_ACCOUNT);
    String url = (Config.url +
        "/api/resource?page=1&resid=" +
        Tool.get(uid) +
        "&filename=" +
        searchValue +
        "&type=" +
        type);
    print(url);
    final response = await dio.get(url);
    jsonRes = json.decode(Tool.decode(response.toString()));
    setState(() {
      for (var dataItem in jsonRes['data']) {
        names.add(dataItem);
      }
    });

    if (jsonRes['next'] == "noexist") {
      setState(() {
        haveData = false;
      });
    } else {
      setState(() {
        pageNo++;
        haveData = true;
      });
    }
  }

  @override
  void initState() {
    _getHotSearch();
    setState(() {
      _saved = Stars.stars;
    });
    super.initState();
    _tabController = new TabController(vsync: this, length: myTabs.length);
    _tabController.addListener(() {
      if (_tabController.index.toDouble() == _tabController.animation.value) {
        setState(() {
          pageNo = 1;
          type = myTabs[_tabController.index].text;
          names.clear();
        });
        _getMoreData();
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (haveData) {
          _getMoreData();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Widget search() {
    return Container(
      // 修饰搜索框, 白色背景与圆角
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
      ),
      alignment: Alignment.center,
      height: 45,
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      child: buildTextField(),
    );
  }

  Widget buildTextField() {
    // theme设置局部主题
    return Theme(
      data: new ThemeData(primaryColor: Colors.grey),
      child: new TextField(
        cursorColor: Colors.grey, // 光标颜色
        // 默认设置
        decoration: InputDecoration(
            border: InputBorder.none,
            icon: Icon(Icons.search),
            hintText: "搜索",
            hintStyle: new TextStyle(
                fontSize: 16, color: Color.fromARGB(50, 0, 0, 0))),
        onChanged: (value) {
          setState(() {
            pageNo = 1;
            names.clear();
            searchValue = value;
          });
          _getMoreData();
        },
        style: new TextStyle(fontSize: 14, color: Colors.black),
      ),
    );
  }

  Widget _buildHot() {
    return Column(
      children: <Widget>[
        Container(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.only(top: 30, left: 23),
              child: Text(
                "热门搜索",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )),
        SizedBox(
          height: 10,
        ),
        SingleChildScrollView(
          child: Wrap(
            spacing: 15,
            children: List.generate(hots.length, (index) {
              return RawChip(
                pressElevation: 12,
                onPressed: () {
                  setState(() {
                    pageNo = 1;
                    searchValue = hots[index]["keyword"];
                    names.clear();
                  });
                  _getMoreData();
                },
                label: Text(hots[index]["keyword"],
                    style: TextStyle(fontSize: 14)),
              );
            }),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: new AppBar(
              automaticallyImplyLeading: false,
              title: search(),
              backgroundColor: Colors.lightBlue,
              bottom: TabBar(
                isScrollable: true,
                unselectedLabelColor: Colors.greenAccent,
                indicatorColor: Colors.orange[500],
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 10.0,
                controller: _tabController,
                tabs: myTabs,
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: myTabs.map((Tab tab) {
                return names.length == 0
                    ? _buildHot()
                    : RefreshIndicator(
                        onRefresh: _onRefresh, child: _buildList());
              }).toList(),
            ),
          )),
      onWillPop: () async {
        // 点击返回键的操作
        if (lastPopTime == null ||
            DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
          lastPopTime = DateTime.now();
          Tool.toast('再按一次退出', Colors.lightBlue[200]);
        } else {
          lastPopTime = DateTime.now();
          // 退出app
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
    );
  }

  Widget _buildList() {
    return ListView.builder(
      ///保持ListView任何情况都能滚动，解决在RefreshIndicator的兼容问题。
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: names.length * 2 + 1,
      itemBuilder: (BuildContext context, int i) {
        if (i % 2 != 0) return new Divider();
        final index = i ~/ 2;
        if (index == names.length) {
          return haveData ? loadMore() : noLoadMore();
        }

        final alreadySaved = _saved.contains((names[index]['rid']));

        String icon = (names[index]['icon']);
        String filename = "";
        if (!(names[index]['name'])
            .toString()
            .contains((names[index]['icon']))) {
          filename = (names[index]['name']).toString();
        } else {
          filename = (names[index]['name'])
              .toString()
              .substring(0, (names[index]['name']).toString().lastIndexOf("."));
        }
        return Container(
          child: ListTile(
            title: Text(
              filename,
              style: TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              (names[index]['formattime']) +
                  "\t\t\t\t" +
                  (names[index]['size']),
              style: TextStyle(fontSize: 13),
            ),
            leading: Image.network(
              Config.url + "/png/$icon.png",
              width: 25,
            ),
            trailing: Container(
                width: 50,
                child: FlatButton(
                    padding: EdgeInsets.all(0),
                    color: Colors.transparent,
                    child: Icon(
                      alreadySaved ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        if (alreadySaved) {
                          _saved.remove((names[index]['rid']));
                          Stars.unstar((names[index]['rid']));
                        } else {
                          _saved.add((names[index]['rid']));
                          Stars.star((names[index]['rid']));
                        }
                      });
                    })),
            onTap: () {
              if (skipView) {
                Tool.pay((names[index]['rid']));
              } else {
                showDialog(
                    context: context,
                    builder: (_) => AssetGiffyDialog(
                          image: Image.asset(
                            "assets/images/load.gif",
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            filename,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 22.0, fontWeight: FontWeight.w600),
                          ),
                          description: Text(
                            '文件大小：' +
                                (names[index]['size']) +
                                '\n分享日期：' +
                                (names[index]['formattime']) +
                                '\n当前积分：' +
                                UserRecord.user.jifen,
                            textAlign: TextAlign.left,
                            style: TextStyle(),
                          ),
                          entryAnimation: EntryAnimation.DEFAULT,
                          onOkButtonPressed: () {
                            Tool.pay((names[index]['rid']));
                          },
                          buttonOkText: Text("下载"),
                          buttonCancelText: Text("不需要"),
                        ));
              }
            },
          ),
        );
      },
      controller: _scrollController,
    );
  }
}
