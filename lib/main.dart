import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

Future<Eau> fetchEau() async {
  try {
    final url = Uri.parse(
        "https://hubeau.eaufrance.fr/api/v2/qualite_rivieres/analyse_pc?"
            "code_departement=75&size=5"
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    print("Statut : ${response.statusCode} | Taille : ${response.body.length} octets");

    if (response.statusCode == 200 || response.statusCode == 206) {
      if (response.body.isEmpty) {
        throw Exception("Réponse vide");
      }
      return Eau.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erreur HTTP ${response.statusCode}");
    }
  } catch (e) {
    print("Erreur : $e");
    rethrow;
  }
}
class Eau {
  final List<StationAnalyse> data;

  Eau({required this.data});

  factory Eau.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    //print("Number of stations: ${dataList.length}"); // Debug
    return Eau(
      data: dataList
          .map((e) => StationAnalyse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StationAnalyse {
  final String codeStation;
  final String libelleStation;
  final String? datePrelevement;
  final String? codeParametre;
  final double? resultat;

  StationAnalyse({
    required this.codeStation,
    required this.libelleStation,
    this.datePrelevement,
    this.codeParametre,
    this.resultat,
  });

  factory StationAnalyse.fromJson(Map<String, dynamic> json) {
    return StationAnalyse(
      codeStation: json['code_station'] ?? 'Inconnu',
      libelleStation: json['libelle_station'] ?? 'Station sans nom',
      datePrelevement: json['date_prelevement'],
      codeParametre: json['code_parametre'],
      resultat: (json['resultat'] != null) ? double.tryParse(json['resultat'].toString()) : null,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Eau> futureEau;

  @override
  void initState() {
    super.initState();
    futureEau = fetchEau();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eau France API',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Stations Eau France')),
        body: Center(
          child: FutureBuilder<Eau>(
            future: futureEau,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 50),
                    const SizedBox(height: 20),
                    Text(
                      'Erreur: ${snapshot.error}',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          futureEau = fetchEau();
                        });
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                );
              } else if (snapshot.hasData) {
                if (snapshot.data!.data.isEmpty) {
                  return const Text('Aucune donnée disponible');
                }
                return ListView.builder(
                  itemCount: snapshot.data!.data.length,
                  itemBuilder: (context, index) {
                    final station = snapshot.data!.data[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(station.libelleStation),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Code: ${station.codeStation}"),
                            if (station.resultat != null)
                              Text("Résultat: ${station.resultat!.toStringAsFixed(2)}"),
                            if (station.datePrelevement != null)
                              Text("Date: ${station.datePrelevement}"),
                            if (station.codeParametre != null)
                              Text("Paramètre: ${station.codeParametre}"),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const Text('État inconnu');
            },
          ),
        ),
      ),
    );
  }
}