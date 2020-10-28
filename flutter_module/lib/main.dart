import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter/services.dart';

void main() => runApp(MyApp(pageIndex:window.defaultRouteName));


class MyApp extends StatefulWidget {
  //此pageIndex是defaultRouteName 外部传进来的默认值跳转的
  final String pageIndex;
  const MyApp({Key key, this.pageIndex}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final MethodChannel _oneChannel = MethodChannel('one_page');
  final MethodChannel _twoChannel = MethodChannel('two_page');
  final MethodChannel _threeChannel = MethodChannel('three_page');

  //在flutter中是一个对象
  final BasicMessageChannel _basicMessageChannel =  BasicMessageChannel('basicMessageChannel',StandardMessageCodec());
  //
  final EventChannel _eventChannel = EventChannel('pass_nativeToFlutter');

  String _privateString = "3";

  //此值是自己内部自己的page，通过channel传参过来赋值的
  String _pageIndex = 'one';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //MethodChannel
    _oneChannel.setMethodCallHandler(invokeFlutterPageMethod);

    _twoChannel.setMethodCallHandler(invokeFlutterPageMethod);
//    _twoChannel.setMethodCallHandler((MethodCall call){
//      _pageIndex = call.method;
//      setState(() {});
//    });

    _threeChannel.setMethodCallHandler(invokeFlutterPageMethod);

    //BasicMessageChannel
    _basicMessageChannel.setMessageHandler((message){
      print('收到了来自ios的:$message');
    });


    //EventChannel
    _eventChannel.receiveBroadcastStream().listen(_getEventPassData,onError: _getError);

    print('invoke----:$_pageIndex');

   }

   Future <Null> invokeFlutterPageMethod(MethodCall call) async{
    _pageIndex = call.method;
    print('invokeFlutterPageMethod:$_pageIndex');
    setState(() {
    });
   }

   //EventChannel 接受到的数据
   void _getEventPassData(dynamic data){
    _privateString = data.toString();
    setState(() { });
   }
   void _getError(Object error){
   }


  @override
  Widget build(BuildContext context) {

//    print('----app传入-----:${widget.pageIndex}');


    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: rootPage(_pageIndex)
    );
  }




  Widget rootPage(String pageIndex){
    print(pageIndex);
    switch(pageIndex){
      case 'one' :
        return  Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              GestureDetector(
                onTap: (){
                  //想调用原生的方法
                  _oneChannel.invokeMethod('exit','passStr:onePage');
                },
                child: Container(
                  width: 150,
                  height: 50,
                  color: Colors.grey,
                  child:  Text('one-返回',style: TextStyle(fontSize: 30,),textAlign: TextAlign.center,),
                ),
              ),

              //
              TextField (
                decoration: InputDecoration(
                  labelText:'需要返回值',
                  hintText: '请输入值',
                ),
                onChanged: (String value){
                  _basicMessageChannel.send(value);

                },
              ),
            ],
          ),
        );

      case 'two' :
        return Center(
          child:GestureDetector(
            onTap: (){
              _twoChannel.invokeMethod('exit','passStr:twoPage');
            },
            child: Container(
              width: 150,
              height: 50,
              color: Colors.grey,
              child:  Text('two',style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
            ),
          ),
        );

      case 'three' :
        return  Center(
            child: GestureDetector(
              onTap: (){
                //想调用原生的方法
                _threeChannel.invokeMethod('exit','passStr:threePage');
              },
              child: Container(
                width: 240,
                height: 50,
                color: Colors.grey,
                child:  Text(_privateString,style: TextStyle(fontSize: 20,),textAlign: TextAlign.center,),
              ),
            )
        );



      default:
        return Center(child: Text('default'),);
    }
  }

}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child:  Text(
          '首页',
        ),
      ),
    );
  }
}
