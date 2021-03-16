import 'package:demo/bean/Vips.dart';
import 'package:demo/util/tool.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:demo/widget/load.dart';
import 'package:flutter/services.dart';

class VipPage extends StatefulWidget {
  @override
  _VipsState createState() => _VipsState();
}

class _VipsState extends State<VipPage> {
  DateTime lastPopTime;
  var names;

  Future init() async {
    try {
      await Vips.initVips();
      setState(() {
        names = Vips.names;
      });
    } catch (e) {}
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<dynamic> _onRefresh() async {
    names.removeRange(0, names.length);
    init();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text("捐赠墙"),
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              tooltip: "公告",
              icon: const Icon(FontAwesomeIcons.bell),
              onPressed: () {
                Navigator.pushNamed(context, '/noties');
              },
            );
          }),
          actions: <Widget>[
            IconButton(
                icon: Icon(FontAwesomeIcons.questionCircle),
                onPressed: () {
                  showDialog<Null>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return new AlertDialog(
                        title: new Text(
                          '帮助',
                          style: TextStyle(fontSize: 14),
                        ),
                        content: new SingleChildScrollView(
                          child: new ListBody(
                            children: <Widget>[
                              Text(
                                "只显示有名字的，不显示编号xxx",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text('关闭'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  ).then((val) {
                    print(val);
                  });
                })
          ],
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan, Colors.blue, Colors.blueAccent],
              ),
            ),
          ),
        ),
        //drawer: CeBianLan(),
        body: null == names || names.length == 0
            ? loadMore()
            : RefreshIndicator(onRefresh: _onRefresh, child: _buildList()),
        resizeToAvoidBottomPadding: false,
      ),
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
      itemCount: names.length * 2,
      itemBuilder: (BuildContext context, int i) {
        if (i % 2 != 0) return new Divider();
        final index = i ~/ 2;
        return Container(
          child: ListTile(
              title: Text(
                names[index],
                style: TextStyle(fontSize: 14),
              ),
              leading: Icon(
                FontAwesomeIcons.user,
                color: Colors.lightBlue,
              )),
        );
      },
    );
  }
}
