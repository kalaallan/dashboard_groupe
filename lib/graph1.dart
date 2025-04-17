import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Pour le formatage des dates
import '../../models/indicateur.dart';
import '../colors/app_colors.dart';

class Graph1 extends StatelessWidget {
  const Graph1({
    super.key,
    required this.isShowingMainData,
    required this.indicateur,
  });

  final bool isShowingMainData; // Permet de basculer entre deux jeux de données si besoin
  final List<Indicateur> indicateur; // Liste des indicateurs à afficher

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineTouchData: lineTouchData1, // Gestion des interactions tactiles et affichage des tooltips
        gridData: gridData, // Options d'affichage de la grille
        titlesData: titlesData1, // Configuration des titres (axes)
        borderData: borderData, // Définition des bordures du graphique
        lineBarsData: _generateChartBars(), // Les courbes (les données) du graphique
        minX: 0,
        maxX: grouped.length.toDouble(), // L'axe des X s'étend sur le nombre de groupes obtenus
        maxY: 5,
        minY: 0,
      ),
      duration: const Duration(milliseconds: 250), // Animation lors du changement de données
    );
  }

  /// Calcule le quartile à un percentile donné dans une liste de valeurs.
  ///
  /// [values] : liste des valeurs sur lesquelles calculer le quartile.
  /// [percentile] : le percentile à calculer (ex. 0.25 pour le 25e percentile,
  /// 0.50 pour la médiane, 0.75 pour le 75e percentile, 1.0 pour le maximum).
  double calculateQuartile(List<double> values, double percentile) {
    if (values.isEmpty) return 0.0;
    // Trie les valeurs pour être sûr d'avoir l'ordre croissant
    values.sort();
    // Calcule l'indice correspondant au percentile
    final double index = percentile * (values.length - 1);
    final int lower = index.floor();
    final int upper = index.ceil();

    // Si l'indice est entier, retourne directement la valeur
    if (lower == upper) {
      return values[lower];
    } else {
      // Sinon, fait une interpolation linéaire entre les deux valeurs
      final double weight = index - lower;
      return values[lower] * (1 - weight) + values[upper] * weight;
    }
  }

  /// Génère une liste de points (FlSpot) pour un quartile donné, pour chaque groupe d'indicateurs.
  ///
  /// [valueExtractor] est une fonction qui extrait une valeur (de type double?) d'un objet Indicateur.
  /// [percentile] est le percentile à calculer pour chaque groupe.
  List<FlSpot> getQuartileSpots(
      double? Function(Indicateur e) valueExtractor, double percentile) {
    return List.generate(grouped.length, (index) {
      // Pour chaque groupe, on extrait les valeurs et on filtre les null
      final group = grouped[index];
      final values = group
          .map(valueExtractor)
          .whereType<double>()
          .toList();

      // Calcul du quartile correspondant pour le groupe
      final q = calculateQuartile(values, percentile);
      // Retourne un point avec l'index en abscisse et la valeur du quartile en ordonnée
      return FlSpot(index.toDouble(), q);
    });
  }

  /// Regroupe les indicateurs par tranche de 45 jours.
  ///
  /// Cette méthode filtre d'abord les indicateurs dont la date d'opération n'est pas nulle,
  /// puis les trie par ordre chronologique et les regroupe par tranche de 45 jours.
  List<List<Indicateur>> get grouped {
    if (indicateur.isEmpty) return [];

    // Filtre les données pour ne conserver que celles avec une date d'opération valide
    final validData = indicateur.where((ind) => ind.dateOperation != null).toList();

    // Trie les données par date croissante
    validData.sort((a, b) =>
        a.dateOperation!.compareTo(b.dateOperation!));

    final List<List<Indicateur>> result = [];

    // Définition de la plage du premier groupe
    DateTime start = validData.first.dateOperation!;
    DateTime end = start.add(const Duration(days: 45));
    List<Indicateur> currentGroup = [];

    // Regroupe les indicateurs dans des tranches de 45 jours
    for (var ind in validData) {
      final date = ind.dateOperation!;
      if (date.isBefore(end)) {
        currentGroup.add(ind);
      } else {
        // Lorsque la date dépasse la plage, on ajoute le groupe courant au résultat
        result.add(currentGroup);
        // On démarre un nouveau groupe
        currentGroup = [ind];
        start = date;
        end = start.add(const Duration(days: 45));
      }
    }

    if (currentGroup.isNotEmpty) result.add(currentGroup);

    return result;
  }

  /// Calcul simple de la moyenne pour iprNote pour chaque groupe (non utilisé dans le calcul des quartiles).
  List<FlSpot> get iprNoteSpots {
    return List.generate(grouped.length, (index) {
      final group = grouped[index];
      // Calcule la somme de iprNote pour le groupe et la divise par le nombre d'éléments
      final sum = group.map((e) => e.iprNote ?? 0.0).reduce((a, b) => a + b);
      final avg = sum / group.length;
      return FlSpot(index.toDouble(), avg);
    });
  }

  /// Calcul simple de la moyenne pour iprplusNote pour chaque groupe (non utilisé dans le calcul des quartiles).
  List<FlSpot> get iprPlusNoteSpots {
    return List.generate(grouped.length, (index) {
      final group = grouped[index];
      final sum = group.map((e) => e.iprplusNote ?? 0.0).reduce((a, b) => a + b);
      final avg = sum / group.length;
      return FlSpot(index.toDouble(), avg);
    });
  }

  /// Génère les courbes (LineChartBarData) pour afficher les différents quartiles de iprplusNote.
  ///
  /// Ici, on affiche 4 courbes correspondant :
  /// - Q1 (25e percentile) en bleu
  /// - Q2 (médiane, 50e percentile) en vert
  /// - Q3 (75e percentile) en orange
  /// - Q4 (100e percentile, maximum) en rouge
  List<LineChartBarData> _generateChartBars() {
    return [
      // Quartile 1 (25%)
      LineChartBarData(
        isCurved: true,
        color: Colors.blue,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: getQuartileSpots((e) => e.iprplusNote, 0.25),
      ),
      // Médiane (Q2, 50%)
      LineChartBarData(
        isCurved: true,
        color: Colors.green,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: getQuartileSpots((e) => e.iprplusNote, 0.50),
      ),
      // Quartile 3 (75%)
      LineChartBarData(
        isCurved: true,
        color: Colors.orange,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: getQuartileSpots((e) => e.iprplusNote, 0.75),
      ),
      // Maximum (Q4, 100%)
      LineChartBarData(
        isCurved: true,
        color: Colors.red,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: getQuartileSpots((e) => e.iprplusNote, 1.0),
      ),
    ];
  }

  /// Configuration de l'interaction tactile et des tooltips sur le graphique.
  LineTouchData get lineTouchData1 => LineTouchData(
    handleBuiltInTouches: true,
    touchTooltipData: LineTouchTooltipData(
      tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
    ),
  );

  /// Configuration de l'affichage de la grille dans le graphique.
  FlGridData get gridData => const FlGridData(show: true);

  /// Configuration des bordures du graphique.
  FlBorderData get borderData => FlBorderData(
    show: true,
    border: Border(
      bottom: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      left: const BorderSide(color: Colors.transparent),
      right: const BorderSide(color: Colors.transparent),
      top: const BorderSide(color: Colors.transparent),
    ),
  );

  /// Configuration des titres sur les axes (abscisse et ordonnée)
  FlTitlesData get titlesData1 => FlTitlesData(
    // Titres de l'axe des abscisses
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        // Affiche la date de début de chaque groupe dans le format "dd/MM"
        getTitlesWidget: (value, meta) {
          final int index = value.toInt();
          if (index < grouped.length) {
            final date = grouped[index].first.dateOperation!;
            final formatter = DateFormat('dd/MM');
            return Text(formatter.format(date), style: const TextStyle(fontSize: 10));
          } else {
            return const Text('');
          }
        },
      ),
    ),
    // Titres de l'axe des ordonnées
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        interval: 1,
        getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(1)),
      ),
    ),
    // On ne montre pas de titres pour les axes droit et supérieur
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
  );
}