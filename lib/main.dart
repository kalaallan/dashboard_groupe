import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true, // Utilisation de Material 3
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Etat piscicole des cours d'eau"),
          centerTitle: true,
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // Positionne le contenu en haut
          crossAxisAlignment: CrossAxisAlignment.start,
          // Aligne la carte à gauche
          children: [
            SizedBox(height: 10), // Ajoute un espace vide
            Expanded(child: MainMapp()),
            Column(
              children : [
                  Card.outlined(child: _SampleCard(cardName: 'Outlined Card')),
                  Card.outlined(child: _SampleCard(cardName: 'Outlined Card')),
                  Card.outlined(child: _SampleCard(cardName: 'Outlined Card')),
              ]
            )
          ],
        ),
      ),
    );

  }
}




class MainMapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(46.603354, 1.888334), // Centre sur la France
        initialZoom: 6.3,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(48.8566, 2.3522), // Coordonnées de Paris
              width: 80,
              height: 80,
              child: GestureDetector(
                onTap: () {
                  print("Bouton Paris Cliqué");
                },
                child: Icon(Icons.location_on, size: 30, color: Colors.red),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class _SampleCard extends StatelessWidget {
  const _SampleCard({required this.cardName});
  final String cardName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 300, height: 100, child: Center(child: Text(cardName)));
  }
}



class firstCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10), // Ajoute de l'espace autour de la carte
      child: InkWell(
        onTap: () {
          print('Card Tapped!');
        },
        child: Card(
          color: Colors.grey[300], // Couleur de fond de la carte
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Coins arrondis
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            // Ajout d'un peu d'espace autour du texte
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // Alignement du texte à gauche
              mainAxisSize: MainAxisSize.min,
              // Taille minimale requise
              children: <Widget>[
                Text(
                  "Batterie interne de l'ECS 2",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Divider(color: Colors.grey),
                Text("Nombre : 1x 12V"),
                Text("Capacité : 4 Ah"),
                Text("Date d'installation : "),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class twoButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(padding: EdgeInsets.all(6)),
        const SizedBox(height: 15),
        FilledButton(
          onPressed: () {
            print('Boutton Tension appuyé'); //action du boutton Tension
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              Colors.orangeAccent,
            ), // Fond jaune
            foregroundColor: WidgetStateProperty.all(
              Colors.black,
            ), // Texte en noir
          ),
          child: const Text('Tension'),
        ),
        Padding(padding: EdgeInsets.all(10)),
        const SizedBox(height: 15),
        FilledButton(
          onPressed: () {
            print('Bouton Etat visuel appuyé'); //action du boutton Etat visuel
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              Colors.orangeAccent,
            ), // Fond jaune
            foregroundColor: WidgetStateProperty.all(Colors.black),
          ), // Texte en noir
          child: const Text('Etat visuel'),
        ),
      ],
    );
  }
}

class SegmentedPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(padding: EdgeInsets.all(6)),
        // C'est ici pour l'espace de marge
        const SizedBox(height: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisSize: MainAxisSize.max,
          children: [
            Text('Etat visuel des batteries'),
            Padding(
              padding: EdgeInsets.all(1), // Ajoute de la zone de texte
            ),
            SimlpleChoix1(),
            Padding(
              padding: EdgeInsets.all(5), // Ajoute de la zone de texte
            ),
            Text('Intensités : comparaison avec les mesures précédentes'),
            Padding(
              padding: EdgeInsets.all(1), // Ajoute de la zone de texte
            ),
            SimlpleChoix3(),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisSize: MainAxisSize.max,
          children: [
            Text('Etat visuel des batteries'),
            Padding(
              padding: EdgeInsets.all(1), // Ajoute de la zone de texte
            ),
            SimlpleChoix1(),
            Padding(
              padding: EdgeInsets.all(32), // Ajoute de la zone de texte
            ),
          ],
        ),
      ],
    );
  }
}

enum Choix1 { S, NS }

class SimlpleChoix1 extends StatefulWidget {
  const SimlpleChoix1({super.key});

  @override
  State<SimlpleChoix1> createState() => _SimlpleChoixState1();
}

class _SimlpleChoixState1 extends State<SimlpleChoix1> {
  Choix1 SP1 = Choix1.S;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Choix1>(
      segments: const <ButtonSegment<Choix1>>[
        ButtonSegment<Choix1>(value: Choix1.S, label: Text('Satisfaisant')),
        ButtonSegment<Choix1>(
          value: Choix1.NS,
          label: Text('Non Satisfaisant'),
        ),
      ],
      selected: <Choix1>{SP1},
      onSelectionChanged: (Set<Choix1> newSelection) {
        setState(() {
          // By default there is only a single segment that can be
          // selected at one time, so its value is always the first
          // item in the selected set.
          SP1 = newSelection.first;
        });
      },
    );
  }
}

enum Choix2 { S, NS }

class SimlpleChoix2 extends StatefulWidget {
  const SimlpleChoix2({super.key});

  @override
  State<SimlpleChoix2> createState() => _SimlpleChoixState2();
}

class _SimlpleChoixState2 extends State<SimlpleChoix2> {
  Choix2 SP2 = Choix2.S;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Choix2>(
      segments: const <ButtonSegment<Choix2>>[
        ButtonSegment<Choix2>(value: Choix2.S, label: Text('Satisfaisant')),
        ButtonSegment<Choix2>(
          value: Choix2.NS,
          label: Text('Non Satisfaisant'),
        ),
      ],
      selected: <Choix2>{SP2},
      onSelectionChanged: (Set<Choix2> newSelection) {
        setState(() {
          // By default there is only a single segment that can be
          // selected at one time, so its value is always the first
          // item in the selected set.
          SP2 = newSelection.first;
        });
      },
    );
  }
}

enum Choix3 { S, NS }

class SimlpleChoix3 extends StatefulWidget {
  const SimlpleChoix3({super.key});

  @override
  State<SimlpleChoix3> createState() => _SimlpleChoixState3();
}

class _SimlpleChoixState3 extends State<SimlpleChoix3> {
  Choix3 SP3 = Choix3.S;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Choix3>(
      segments: const <ButtonSegment<Choix3>>[
        ButtonSegment<Choix3>(value: Choix3.S, label: Text('Satisfaisant')),
        ButtonSegment<Choix3>(
          value: Choix3.NS,
          label: Text('Non Satisfaisant'),
        ),
      ],
      selected: <Choix3>{SP3},
      onSelectionChanged: (Set<Choix3> newSelection) {
        setState(() {
          // By default there is only a single segment that can be
          // selected at one time, so its value is always the first
          // item in the selected set.
          SP3 = newSelection.first;
        });
      },
    );
  }
}

class firstFieldText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(padding: EdgeInsets.all(6)),
        const SizedBox(height: 15),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'En charge',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 10), // Ajoute un espace vide
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'En début de décharge',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 10), // Ajoute un espace vide
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Après 1h de décharge',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.all(6)),
        const SizedBox(height: 15),
      ],
    );
  }
}

class secondFieldText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(padding: EdgeInsets.all(6)),
        const SizedBox(height: 15),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Intensité en veille à T0',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 10), // Ajoute un espace vide
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Intensité en alarme',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 10), // Ajoute un espace vide
        Expanded(
          child: TextField(
            enabled: false, // Pour empêcher l'écriture
            decoration: InputDecoration(
              labelText: 'Consommation Calculée',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.all(6)),
        const SizedBox(height: 15),
      ],
    );
  }
}
