import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

//import 'station_marker_loader.dart';
import 'dart:convert';
import 'package:flutter/services.dart' as services;
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart' as pie;
import 'package:fl_chart/fl_chart.dart' as fl;

class StationMarkerLoader {
  static Future<List<Marker>> loadMarkersFromAssetWithCallback(
    Function(String) onTapCallback,
  ) async {
    try {
      String jsonString = await services.rootBundle.loadString(
        'assets/indicateurs.json',
      );
      var jsonData = jsonDecode(jsonString);

      if (jsonData != null &&
          jsonData['data'] != null &&
          jsonData['data'] is List) {
        List<dynamic> features = jsonData['data'];
        List<Marker> markersList = [];

        for (var feature in features.take(1000)) {
          if (feature['libelle_station'] != null &&
              feature['latitude'] != null &&
              feature['longitude'] != null) {
            String libelleStation = feature['libelle_station'];
            double latitude = feature['latitude'];
            double longitude = feature['longitude'];

            markersList.add(
              Marker(
                point: LatLng(latitude, longitude),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    print("$libelleStation cliqué");
                    onTapCallback(libelleStation);
                  },
                  child: Icon(Icons.location_on, size: 15, color: Colors.red),
                ),
              ),
            );
          }
        }
        return markersList;
      } else {
        return [];
      }
    } catch (e) {
      print("Erreur lors du chargement des marqueurs : $e");
      return [];
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String selectedStation = 'Aucune';
  Map<String, Map<String, double>> stationFishData = {}; // Toutes les données espèces/stations
  Map<String, double> pieData = {}; // Données à afficher dans le PieChart

  void updateSelectedStation(String name) {
    setState(() {
      selectedStation = name;
      pieData = stationFishData[name] ?? {}; // Données PieChart à jour
    });
  }

  final String defaultStation = "TUSSON à EVAILLE";

  @override
  void initState() {
    super.initState();
    loadFishData(); // Appelé une seule fois au démarrage de l'app
  }

  Future<void> loadFishData() async {
    String jsonString =
    await services.rootBundle.loadString('assets/indicateurs.json');
    var jsonData = jsonDecode(jsonString);

    if (jsonData['data'] != null && jsonData['data'] is List) {
      for (var station in jsonData['data']) {
        if (station['libelle_station'] != null &&
            station['ipr_noms_communs_taxon'] != null &&
            station['ipr_effectifs_taxon'] != null) {
          String name = station['libelle_station'];
          List noms = station['ipr_noms_communs_taxon'];
          List effectifs = station['ipr_effectifs_taxon'];

          Map<String, double> fishData = {};
          for (int i = 0; i < noms.length; i++) {
            int count = effectifs[i];
            if (count > 0) {
              fishData[noms[i]] = count.toDouble();
            }
          }
          stationFishData[name] = fishData;
        }
      }
    }
    if (stationFishData.containsKey(defaultStation)) {
      updateSelectedStation(defaultStation); // Affiche la station par défaut
    }
  }

  List<fl.BarChartGroupData> getBarChartData() {
    List<fl.BarChartGroupData> barGroups = [];
    int index = 0;
    pieData.forEach((name, count) {
      barGroups.add(
        fl.BarChartGroupData(
          x: index,
          barRods: [
            fl.BarChartRodData(
              toY: count,
              color: Colors.blue,
              width: 6,
              borderRadius: BorderRadius.circular(6),
              // Ajoute le texte directement ici
              rodStackItems: [],
              backDrawRodData: fl.BackgroundBarChartRodData(
                show: true,
                toY: 0,
                color: Colors.transparent,
              ),
            ),
          ],
          showingTooltipIndicators: [],
        ),
      );
      index++;
    });
    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    //loadStations();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Circular',
        useMaterial3: true, // Utilisation de Material 3
      ),
      home: Scaffold(
        backgroundColor: Colors.grey[200], // Choix de la couleur
        appBar: AppBar(
          backgroundColor: Colors.grey[200], // Choix de la couleur
          title: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            // espace au-dessus du titre
            child: Text(
              "Dashboard des états piscicole des bassins et cours d'eau",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          centerTitle: true,
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // Positionne le contenu en haut
          crossAxisAlignment: CrossAxisAlignment.start,
          // Aligne la carte à gauche
          children: [
            SizedBox(height: 10), // Ajoute un espace vide
            Expanded(
              flex: 1, // 50% de la page
              child: Padding(
                padding: const EdgeInsets.all(16.0), // marge sur tous les côtés
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // couleur jsp
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: MainMapp(onStationSelected: updateSelectedStation),
                  ),
                ),
              ),
            ),
// ---------------- CONTENEUR DROIT ----------------------
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        // Titre centré
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Station sélectionnée : $selectedStation',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Graphique en camembert / pie chart
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                //[100], // couleur du fond du pie chart
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  //l'ombre sous les conteneur
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    double containerWidth = constraints.maxWidth;
                                    double fontSize = (containerWidth / (pieData.length + 4)).clamp(8, 16);

                                    return pie.PieChart(
                                      dataMap: pieData.isNotEmpty ? pieData : {"Aucune donnée": 1},
                                      chartType: pie.ChartType.disc,
                                      chartValuesOptions: pie.ChartValuesOptions(
                                        showChartValues: false,
                                        showChartValuesInPercentage: false,
                                        showChartValueBackground: false,
                                      ),
                                      legendOptions: pie.LegendOptions(
                                        showLegends: true,
                                        legendPosition: pie.LegendPosition.right,
                                        legendTextStyle: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                              ),
                            ),
                          ),
                        ),

                        // Graphique à barres / Histogramme
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                //[100], //couleur de l'histogramme
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  // Ombre sous le conteneur
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: fl.BarChart(
                                  fl.BarChartData(
                                    barGroups: getBarChartData(),
                                    borderData: fl.FlBorderData(show: false),
                                    titlesData: fl.FlTitlesData(
                                      leftTitles: fl.AxisTitles(
                                        sideTitles: fl.SideTitles(showTitles: false),
                                      ),
                                      rightTitles: fl.AxisTitles(
                                        sideTitles: fl.SideTitles(showTitles: false),
                                      ),
                                      topTitles: fl.AxisTitles(
                                        sideTitles: fl.SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final keys = pieData.keys.toList();
                                            final values = pieData.values.toList();
                                            if (value.toInt() < values.length) {
                                              return Text('${values[value.toInt()].toInt()}',
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
                                            } else {
                                              return Text('');
                                            }
                                          },
                                        ),
                                      ),
                                      bottomTitles: fl.AxisTitles(
                                        sideTitles: fl.SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final keys = pieData.keys.toList();
                                            return Transform.rotate(
                                              angle: -0.5,
                                              child: Text(
                                                value.toInt() < keys.length ? keys[value.toInt()] : '',
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            );
                                          },
                                          reservedSize: 60,
                                        ),
                                      ),
                                    ),

                                    gridData: fl.FlGridData(show: true),
                                  ),
                                ),

                              ),
                            ),
                          ),
                        ),
                        // ➕ Graphique supplémentaire (Graph1)
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Graph1(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainMapp extends StatefulWidget {
  final Function(String) onStationSelected;

  const MainMapp({Key? key, required this.onStationSelected}) : super(key: key);

  @override
  _MainMappState createState() => _MainMappState();
}

class _MainMappState extends State<MainMapp> {
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _loadMarkers(); // Charger une seule fois
  }

  void _loadMarkers() async {
    final markers = await StationMarkerLoader.loadMarkersFromAssetWithCallback((
      stationName,
    ) {
      widget.onStationSelected(stationName); // Appelle le callback externe
    });
    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(46.603354, 1.888334),
        initialZoom: 6.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(markers: _markers),
      ],
    );
  }
}

// Graph 1
class Graph1 extends StatelessWidget {
  const Graph1({super.key});

  @override
  Widget build(BuildContext context) {
    return fl.LineChart(
      fl.LineChartData(
        lineBarsData: [
          fl.LineChartBarData(
            isCurved: true,
            spots: [
              fl.FlSpot(0, 3),
              fl.FlSpot(1, 4),
              fl.FlSpot(2, 5),
              fl.FlSpot(3, 3.1),
              fl.FlSpot(4, 4.5),
              fl.FlSpot(5, 3.8),
            ],
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: fl.BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
