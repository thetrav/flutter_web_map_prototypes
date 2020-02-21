import 'dart:async';
import 'dart:js';
import 'dart:html';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:google_maps/google_maps.dart' as maps;

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class GoogleMapView extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _GoogleMapViewState();
}

maps.LatLng from(Tuple2<double, double> t) => maps.LatLng(t.item1, t.item2);

class _GoogleMapViewState extends State<GoogleMapView> {
  String key;
  DivElement mapFrame;
  maps.GMap map;
  List<List<Tuple2<double, double>>> polys = [[
    Tuple2(-37.786566781511375, 145.24190953142167),
    Tuple2(-37.78673636101828, 145.24319699174882),
    Tuple2(-37.7869949690171, 145.2431916273308),
    Tuple2(-37.78680843219088, 145.24194708234788)
  ]];
  List<Tuple2<double, double>> currentPoly;
  bool drawingPoly;
  maps.Polygon tempPoly;

  StreamSubscription<maps.MouseEvent> listener;

  void drawPolygon(List<Tuple2<double, double>> points) {
    maps.Polygon(maps.PolygonOptions()
      ..paths = points.map(from).toList()
      ..strokeColor = "#FF0000"
      ..strokeOpacity = 0.8
      ..strokeWeight = 2
      ..fillColor = "#FF0000"
      ..fillOpacity = 0.35
      ..map = map
    );
  }

  @override
  void dispose() {
    super.dispose();
    listener.cancel();
    mapFrame.remove();
  }

  @override
  void initState() {
    super.initState();
    key = math.Random().nextDouble().toString();
    currentPoly = <Tuple2<double, double>>[];
    drawingPoly = false;
    final myLatlng = maps.LatLng(-37.7845, 145.24107);
    final mapOptions = maps.MapOptions()
      ..zoom = 18
      ..center = myLatlng
      ..streetViewControl = false
      ..fullscreenControl = false
      ..mapTypeControl = false
      ..mapTypeId = maps.MapTypeId.SATELLITE
      ..clickableIcons = false
    ;
    mapFrame = DivElement()
      ..id = key
      ..style.width = "100%"
      ..style.height = "100%"
      ..style.border = 'none';
    map = maps.GMap(mapFrame, mapOptions);
    polys.forEach(drawPolygon);
    listener = map.onClick.listen(mapClickEventSink);
    tempPoly = maps.Polygon(maps.PolygonOptions()
      ..strokeColor = "#0000FF"
      ..strokeOpacity = 0.8
      ..strokeWeight = 2
      ..fillColor = "#0000FF"
      ..fillOpacity = 0.35
    );
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(key, (int viewId) => mapFrame);
  }

  void mapClickEventSink(maps.MouseEvent e) {
    maps.LatLng latLng = e.latLng;
    final point = Tuple2<double, double>(
      latLng.lat,
      latLng.lng
    );
    if(drawingPoly) {
      setState((){
        currentPoly.add(point);
        tempPoly.paths = currentPoly.map(from).toList();
      });
    }
  }

  void drawPoly() {
    if(!drawingPoly) {
      setState((){
        drawingPoly = true;
        currentPoly = <Tuple2<double, double>>[];
        tempPoly.paths = JsObject.jsify([]);
        tempPoly.map = map;
      });
    } else {
      setState((){
        polys.add(currentPoly);
        tempPoly.map = null;
        drawPolygon(currentPoly);
        currentPoly = <Tuple2<double, double>>[];
        drawingPoly = false;
      });
    }
  }

  void remove(Tuple2<double, double> p) {
    setState((){
      currentPoly.remove(p);
      tempPoly.paths = currentPoly.map(from).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      RaisedButton(
        child: Text(drawingPoly ? "Finish" : "Start"),
        onPressed: drawPoly
      ),
    ];
    currentPoly.forEach((p) {
      controls.add(
        Row(children: [
          Text("${p.item1.toStringAsFixed(5)}:${p.item2.toStringAsFixed(5)}"),
          FlatButton(child: Icon(Icons.delete, color: Colors.red), onPressed: (){remove(p);})
        ])
      );
    });
    return Row(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 200
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controls
          ),
        ),
        Flexible(child: HtmlElementView(viewType: key)),
      ]
    );
  }
}