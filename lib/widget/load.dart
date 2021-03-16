import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget loading() {
  return Stack(
    children: <Widget>[
      new Padding(
        padding: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 35.0),
        child: new Center(
          child: SpinKitCubeGrid(
            color: Colors.blueAccent,
            size: 30.0,
          ),
        ),
      ),
      new Padding(
        padding: new EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
        child: new Center(
          child: new Text('正在加载中，请稍等。'),
        ),
      ),
    ],
  );
}

Widget loadMore() {
  return Container(
    margin: EdgeInsets.all(10),
    child: Align(
      child: Center(
          child: SpinKitThreeBounce(
        color: Colors.blueAccent,
        size: 30.0,
      )),
    ),
  );
}

Widget noLoadMore() {
  return Container(
    margin: EdgeInsets.all(10),
    child: Align(
      child: Center(child: Text("没有更多了~")),
    ),
  );
}
