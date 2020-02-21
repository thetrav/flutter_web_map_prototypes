import 'package:flutter/material.dart';
import 'dart:html';
import 'dart:js';
import 'dart:ui' as ui;
import 'dart:math' as math;

final accessToken = "see .api_keys in root";

class LeafletMapView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LeafletMapViewState();
}

class _LeafletMapViewState extends State<LeafletMapView> {
  String key;
  DivElement root;
  DivElement mapFrame;
  JsObject map;
  @override
  bool initState() {
    super.initState();
    key = math.Random().nextDouble().toString();
    root = DivElement();

    final style = LinkElement();
    style.rel = "stylesheet";
    style.href="https://unpkg.com/leaflet@1.6.0/dist/leaflet.css";
    style.integrity="sha512-xwE/Az9zrjBIphAcBb3F6JVqxf46+CDLwfLMHloNu6KEQCAWi6HcDUbeOfBIptF7tcCzusKFjFw2yuvEpDL9wQ==";
    style.crossOrigin="";
    root.append(style);

    mapFrame = DivElement()
      ..id = key
      ..style.width = "100%"
      ..style.height = "100%"
      ..style.border = 'none';
    root.append(mapFrame);

    map = context['L']
      .callMethod('map', [mapFrame])
      .callMethod('setView', [JsObject.jsify([-37.7845, 145.24107]), 18]);
    context['L'].callMethod('tileLayer', [
      'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
      JsObject.jsify({
        'attribution': 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
        'maxZoom': 18,
        'id': 'mapbox/satellite-v9',
        'tileSize': 512,
        'zoomOffset': -1,
        'accessToken': accessToken
      })
    ]).callMethod('addTo', [map]);

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(key, (int viewId) => root);
  }

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      Text("controls go in here")
    ];
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