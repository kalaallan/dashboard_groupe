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
    import 'package:flutter/services.dart';

    class StationMarkerLoader {
    static Future<List<Marker>> loadMarkersFromAssetWithCallback(
    Function(String) onTapCallback,
    String? activeStation, // Add activeStation parameter
    ) async {
    try {
    String jsonString = await rootBundle.loadString('assets/indicateurs.json');
    var jsonData = jsonDecode(jsonString);

    if (jsonData != null && jsonData['data'] != null && jsonData['data'] is List) {
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
    child: Icon(
    Icons.location_on,
    size: 15,
    color: activeStation == libelleStation ? Colors.blue : Colors.red,
    ),
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
    Map<String, Map<String, double>> stationFishData =
    {}; // Toutes les données espèces/stations
    Map<String, double> pieData = {}; // Données à afficher dans le PieChart

    String simplifierNomPoisson(String nom) {
    if (nom.contains("Carassin indéterminé")) return "Carassin";
    if (nom.contains("Goujon indéterminé")) return "Goujon";
    if (nom.contains("Vairon indéterminé")) return "Vairon";
    return nom;
    }

    void updateSelectedStation(String name) {
    setState(() {
    selectedStation = name;

    final rawData = stationFishData[name] ?? {};
    final Map<String, double> simplifiedData = {};

    rawData.forEach((key, value) {
    final simplifiedKey = simplifierNomPoisson(key);
    if (value > 0) {
    simplifiedData[simplifiedKey] =
    (simplifiedData[simplifiedKey] ?? 0) + value;
    }
    });

    pieData = simplifiedData;
    });
    }

    final String defaultStation = "TUSSON à EVAILLE";

    @override
    void initState() {
    super.initState();
    loadFishData(); // Appelé une seule fois au démarrage de l'app
    }

    Map<String, String> stationDates = {};  // Map pour stocker les dates de relevé

    Future<void> loadFishData() async {
    String jsonString = await services.rootBundle.loadString(
    'assets/indicateurs.json',
    );
    var jsonData = jsonDecode(jsonString);

    if (jsonData['data'] != null && jsonData['data'] is List) {
    for (var station in jsonData['data']) {
    if (station['libelle_station'] != null &&
    station['ipr_noms_communs_taxon'] != null &&
    station['ipr_effectifs_taxon'] != null &&
    station['date_operation'] != null) {
    String name = station['libelle_station'];
    List noms = station['ipr_noms_communs_taxon'];
    List effectifs = station['ipr_effectifs_taxon'];
    String rawDate = station['date_operation'];

    // Convertir la date
    String formattedDate = formatDate(rawDate);

    Map<String, double> fishData = {};
    for (int i = 0; i < noms.length; i++) {
    int count = effectifs[i];
    if (count > 0) {
    fishData[noms[i]] = count.toDouble();
    }
    }
    stationFishData[name] = fishData;

    // Stocker la dernière date de relevé dans un Map séparé
    stationDates[name] = formattedDate;
    }
    }
    }
    if (stationFishData.containsKey(defaultStation)) {
    updateSelectedStation(defaultStation); // Affiche la station par défaut
    }
    }

    String formatDate(String rawDate) {
    DateTime date = DateTime.parse(rawDate);
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }

    final List<String> poissonsPechables = [
    'Ablette',
    'Barbeau fluviatile',
    'Barbeau méridional',
    'Blageon',
    'Bouvière',
    'Gardon',
    'Goujon indéterminé (Gobio)',
    'Grémille',
    'Hotu',
    'Loche franche',
    'Ombre commun',
    'Perche soleil',
    'Vairon indéterminé (Phoxinus)',
    'Rotengle',
    'Brème commune',
    'Epinoche',
    'Spirlin',
    'Tanche',
    'Vandoise',
    ];

    List<String> getPoissonsPechables() {
    final List<String> listePechables = [
    "Ablette", "Barbeau fluviatile", "Barbeau méridional", "Blageon", "Bouvière",
    "Gardon", "Goujon", "Grémille", "Hotu", "Loche franche", "Ombre commun",
    "Perche soleil", "Vairon", "Rotengle", "Brème commune", "Epinoche",
    "Spirlin", "Tanche", "Vandoise", "Epinochette"
    ];

    final pechables = <String>[];

    pieData.forEach((poisson, effectif) {
    if (listePechables.contains(poisson) && effectif > 100) {
    pechables.add(poisson);
    }
    });

    return pechables;
    }

    List<fl.BarChartGroupData> getBarChartData() {
    List<fl.BarChartGroupData> barGroups = [];

    // Trier les espèces par effectif décroissant et prendre les 5 premières
    final sortedEntries =
    pieData.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topFive = sortedEntries.take(5).toList();

    for (int i = 0; i < topFive.length; i++) {
    barGroups.add(
    fl.BarChartGroupData(
    x: i,
    barRods: [
    fl.BarChartRodData(
    toY: topFive[i].value,
    color: Colors.blue,
    width: 6,
    borderRadius: BorderRadius.circular(6),
    ),
    ],
    ),
    );
    }

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
    resizeToAvoidBottomInset: true,
    backgroundColor: Colors.grey[200], // Choix de la couleur
    appBar: AppBar(
    backgroundColor: Colors.grey[200], // Choix de la couleur
    elevation: 0, // Supprime l’ombre de l’AppBar
    title: Padding(
    padding: const EdgeInsets.only(top: 16.0),
    // espace au-dessus du titre

    child: Text(
    "État piscicole des bassins et cours d'eau",
    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    ),
    centerTitle: true,
    ),
    body: LayoutBuilder(
    builder: (context, constraints) {
    final isWideScreen = constraints.maxWidth >= 1200;

    final leftPanel = Expanded(
    flex: 1,
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Container(
    decoration: BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(20),
    ),
    child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: MainMapp(onStationSelected: updateSelectedStation),
    ),
    ),
    ),
    );

    final rightPanel = Expanded(
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
                          flex: 2,
                          child:Column(
                            children: [
                              Expanded(
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Répartition du nombre de poissons :',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Expanded(
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                double containerWidth = constraints.maxWidth;
                                                double fontSize =
                                                (containerWidth / (pieData.length + 4)).clamp(8, 16);

                                                return pie.PieChart(
                                                  dataMap: pieData.isNotEmpty
                                                      ? pieData
                                                      : {"Aucune donnée": 1},
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
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        ),

                        // Graphique à barres / Histogramme
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              // Histogramme à gauche
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Top 5 nombre de poissons disponibles :',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Expanded(
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
                                                        final sortedEntries = pieData.entries.toList()
                                                          ..sort((a, b) => b.value.compareTo(a.value));
                                                        if (value.toInt() < sortedEntries.length) {
                                                          final entry = sortedEntries[value.toInt()];
                                                          return Text(
                                                            '${entry.value.toInt()}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          );
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
                                                        final sortedKeys = pieData.entries.toList()
                                                          ..sort((a, b) => b.value.compareTo(a.value));
                                                        final topKeys = sortedKeys
                                                            .take(5)
                                                            .map((e) => e.key)
                                                            .toList();

                                                        return Transform.rotate(
                                                          angle: -0.5,
                                                          child: Text(
                                                            value.toInt() < topKeys.length
                                                                ? topKeys[value.toInt()]
                                                                : '',
                                                            style: TextStyle(fontSize: 10),
                                                          ),
                                                        );
                                                      },
                                                      reservedSize: 60,
                                                    ),
                                                  ),
                                                ),
                                                gridData: fl.FlGridData(show: false),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Poissons pêchables à droite
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Poissons pêchables sans réglementations particulières (>100 individus) :',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          ...getPoissonsPechables().map((poisson) => Text(
                                            '- $poisson',
                                            style: TextStyle(fontSize: 14),
                                          )),
                                          if (getPoissonsPechables().isEmpty)
                                            Text(
                                              'Aucun poisson pêchable dans cette station.',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontStyle: FontStyle.italic,
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




                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Dernier relevé disponible pour la station selectionnée : ${stationDates[selectedStation] ?? 'Aucune donnée'}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              //fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            );
            BoxDecoration _boxDecoration() => BoxDecoration(
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
            );

            return isWideScreen
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [leftPanel, rightPanel],
            )
                : SingleChildScrollView(
              child: Builder(builder: (context) {
                final screenHeight = MediaQuery.of(context).size.height;

                // On réserve un % de la hauteur pour chaque composant
                final mapHeight = screenHeight * 0.25;
                final chartHeight = screenHeight * 0.3;

                return Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Carte
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: MainMapp(onStationSelected: updateSelectedStation),
                          ),
                        ),
                      ),

                      // Contenu droit
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Station sélectionnée : $selectedStation',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),

                            // Pie Chart
                            Container(
                              height: 400,
                              padding: const EdgeInsets.all(16.0),
                              decoration: _boxDecoration(),
                              child:
                              Column(
                                children: [
                                  Text(
                                    'Répartition du nombre de poissons :',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 12),
                                  Expanded(
                                    flex: 3,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        double fontSize = (constraints.maxWidth / (pieData.length + 4)).clamp(8, 16);
                                        return pie.PieChart(
                                          dataMap: pieData.isNotEmpty ? pieData : {"Aucune donnée": 1},
                                          chartType: pie.ChartType.disc,
                                          chartValuesOptions: pie.ChartValuesOptions(showChartValues: false),
                                          legendOptions: pie.LegendOptions(
                                            showLegends: true,
                                            legendPosition: pie.LegendPosition.right,
                                            legendTextStyle: TextStyle(fontSize: 14),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16),

                            // Histogramme
                            Container(
                              height: 250,
                              padding: const EdgeInsets.all(16.0),
                              decoration: _boxDecoration(),
                              child: Column(
                                children: [
                                  Text(
                                    'Top 5 nombre de poissons disponibles :',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 12),
                                  Expanded(
                                    child: fl.BarChart(
                                      fl.BarChartData(
                                        barGroups: getBarChartData(),
                                        borderData: fl.FlBorderData(show: false),
                                        titlesData: fl.FlTitlesData(
                                          leftTitles: fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
                                          rightTitles: fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
                                          topTitles: fl.AxisTitles(
                                            sideTitles: fl.SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                final sortedEntries = pieData.entries.toList()
                                                  ..sort((a, b) => b.value.compareTo(a.value));
                                                if (value.toInt() < sortedEntries.length) {
                                                  final entry = sortedEntries[value.toInt()];
                                                  return Text('${entry.value.toInt()}', style: TextStyle(fontSize: 12));
                                                }
                                                return Text('');
                                              },
                                            ),
                                          ),
                                          bottomTitles: fl.AxisTitles(
                                            sideTitles: fl.SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                final sortedKeys = pieData.entries.toList()
                                                  ..sort((a, b) => b.value.compareTo(a.value));
                                                final topKeys = sortedKeys.take(5).map((e) => e.key).toList();

                                                return Transform.rotate(
                                                  angle: -0.5,
                                                  child: Text(
                                                    value.toInt() < topKeys.length ? topKeys[value.toInt()] : '',
                                                    style: TextStyle(fontSize: 10),
                                                  ),
                                                );
                                              },
                                              reservedSize: 60,
                                            ),
                                          ),
                                        ),
                                        gridData: fl.FlGridData(show: false),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16),

                            // Liste poissons
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: _boxDecoration(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Poissons pêchables sans réglementations particulières (>100 individus) :',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 12),
                                  ...getPoissonsPechables().map((poisson) => Text('- $poisson')),
                                  if (getPoissonsPechables().isEmpty)
                                    Text(
                                      'Aucun poisson pêchable dans cette station.',
                                      style: TextStyle(fontStyle: FontStyle.italic),
                                    ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16),

                            // Dernier relevé
                            Text(
                              'Dernier relevé disponible pour la station selectionnée : ${stationDates[selectedStation] ?? 'Aucune donnée'}',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );


          },
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
  String? _activeStation;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  void _loadMarkers() async {
    final markers = await StationMarkerLoader.loadMarkersFromAssetWithCallback(
          (stationName) {
        setState(() {
          _activeStation = stationName;
          _loadMarkers(); // Reload markers to update colors
        });
        widget.onStationSelected(stationName);
      },
      _activeStation, // Pass the active station
    );
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