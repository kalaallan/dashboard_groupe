import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StationData {
  final String libelle;
  final double latitude;
  final double longitude;

  StationData({required this.libelle, required this.latitude, required this.longitude});
}

class StationMarkerLoader {
  static Future<List<StationData>> loadStationsFromAsset() async {
    try {
      String jsonString = await services.rootBundle.loadString('assets/indicateurs.json');
      var jsonData = jsonDecode(jsonString);

      if (jsonData != null && jsonData['data'] != null && jsonData['data'] is List) {
        List<dynamic> features = jsonData['data'];
        return features
            .where((f) => f['libelle_station'] != null && f['latitude'] != null && f['longitude'] != null)
            .map((f) => StationData(
          libelle: f['libelle_station'],
          latitude: f['latitude'],
          longitude: f['longitude'],
        ))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Erreur lors du chargement des stations : $e");
      return [];
    }
  }
}

