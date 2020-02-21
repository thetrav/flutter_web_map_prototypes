import 'package:flutter/material.dart';
import 'package:flutter_map_test/google_map_web.dart';
import 'package:flutter_map_test/leaflet_map_web.dart';

//import 'leaflet_map_web.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        "/": (_) => Wrapper(Text("Use the menu to the left to select map"), true),
        "/Google": (_) => Wrapper(GoogleMapView(), false),
        "/Leaflet": (_) => Wrapper(LeafletMapView(), false),
      }
    );

  }
}

class Wrapper extends StatelessWidget {
  final Widget body;
  final bool menu;
  Wrapper(this.body, this.menu);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map Prototypes"),
      ),
      drawer: menu ? Drawer(child: ListView(children: [
        DrawerHeader(child: Text("Map Prototypes"), decoration: BoxDecoration(color: Colors.blue)),
        FlatButton(child: Text("Leaflet"), onPressed: (){
          Navigator.pushNamed(context, "/Leaflet");
        }),
        FlatButton(child: Text("Google"), onPressed: (){
          Navigator.pushNamed(context, "/Google");
        }),
      ])): null,
      body: Center(child: body),
    );
  }
}

