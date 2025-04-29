import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class StatisticsDashboard extends StatefulWidget {
  @override
  _StatisticsDashboardState createState() => _StatisticsDashboardState();
}

class _StatisticsDashboardState extends State<StatisticsDashboard> {
  late Future<Map<String, dynamic>> _statsData;

  @override
  void initState() {
    super.initState();
    _statsData = _fetchAllStats();
  }

  Future<Map<String, dynamic>> _fetchAllStats() async {
    final articles = await _fetchArticlesStats();
    final demandes = await _fetchDemandesStats();
    final equipements = await _fetchEquipementsStats();
    final maintenances = await _fetchMaintenanceStats();

    return {
      'articles': articles,
      'demandes': demandes,
      'equipements': equipements,
      'maintenances': maintenances,
    };
  }

  Future<Map<String, dynamic>> _fetchArticlesStats() async {
    final snapshot = await FirebaseFirestore.instance.collection('articles').get();
    
    // Statistiques de prix
    double totalPrix = 0;
    double maxPrix = 0;
    double minPrix = double.infinity;
    int count = snapshot.docs.length;
    
    for (var doc in snapshot.docs) {
      final prix = doc['prix']?.toDouble() ?? 0;
      totalPrix += prix;
      if (prix > maxPrix) maxPrix = prix;
      if (prix < minPrix) minPrix = prix;
    }
    
    double avgPrix = count > 0 ? totalPrix / count : 0;
    
    // Distribution des prix
    final prixDistribution = <String, int>{
      '0-50': 0,
      '51-100': 0,
      '101-200': 0,
      '201+': 0,
    };
    
    for (var doc in snapshot.docs) {
      final prix = doc['prix']?.toDouble() ?? 0;
      if (prix <= 50) prixDistribution['0-50'] = prixDistribution['0-50']! + 1;
      else if (prix <= 100) prixDistribution['51-100'] = prixDistribution['51-100']! + 1;
      else if (prix <= 200) prixDistribution['101-200'] = prixDistribution['101-200']! + 1;
      else prixDistribution['201+'] = prixDistribution['201+']! + 1;
    }
    
    return {
      'count': count,
      'avgPrix': avgPrix,
      'maxPrix': maxPrix,
      'minPrix': minPrix == double.infinity ? 0 : minPrix,
      'prixDistribution': prixDistribution,
    };
  }

  Future<Map<String, dynamic>> _fetchDemandesStats() async {
    final snapshot = await FirebaseFirestore.instance.collection('demandes_intervention').get();
    
    // Distribution par statut
    final statusDistribution = <String, int>{
      'validee': 0,
      'en_attente': 0,
      'rejetee': 0,
    };
    
    final urgenceDistribution = <String, int>{
      'faible': 0,
      'moyenne': 0,
      'haute': 0,
    };
    
    // Demandes par technicien
    final demandesParTechnicien = <String, int>{};
    
    for (var doc in snapshot.docs) {
      final status = doc['status'] ?? 'inconnu';
      statusDistribution[status] = (statusDistribution[status] ?? 0) + 1;
      
      final urgence = doc['niveau_urgence'] ?? 'inconnu';
      urgenceDistribution[urgence] = (urgenceDistribution[urgence] ?? 0) + 1;
      
      final technicien = doc['demandeur_nom'] ?? 'Inconnu';
      demandesParTechnicien[technicien] = (demandesParTechnicien[technicien] ?? 0) + 1;
    }
    
    return {
      'count': snapshot.docs.length,
      'statusDistribution': statusDistribution,
      'urgenceDistribution': urgenceDistribution,
      'demandesParTechnicien': demandesParTechnicien,
    };
  }

  Future<Map<String, dynamic>> _fetchEquipementsStats() async {
    final snapshot = await FirebaseFirestore.instance.collection('equipements').get();
    
    return {
      'count': snapshot.docs.length,
      'equipements': snapshot.docs.map((doc) => doc['nom']).toList(),
    };
  }

  Future<Map<String, dynamic>> _fetchMaintenanceStats() async {
    final snapshot = await FirebaseFirestore.instance.collection('maintenance_reports').get();
    
    // Interventions par technicien
    final interventionsParTechnicien = <String, int>{};
    
    // Interventions par équipement
    final interventionsParEquipement = <String, int>{};
    
    // Interventions par mois
    final interventionsParMois = <String, int>{};
    final moisFormatter = DateFormat('MMM yyyy');
    
    for (var doc in snapshot.docs) {
      final timestamp = doc['created_at'] as Timestamp?;
      if (timestamp != null) {
        final mois = moisFormatter.format(timestamp.toDate());
        interventionsParMois[mois] = (interventionsParMois[mois] ?? 0) + 1;
      }
      
      final technicien = doc['technicien_id'] ?? 'Inconnu';
      interventionsParTechnicien[technicien] = (interventionsParTechnicien[technicien] ?? 0) + 1;
      
      final equipement = doc['equipement_id'] ?? 'Inconnu';
      interventionsParEquipement[equipement] = (interventionsParEquipement[equipement] ?? 0) + 1;
    }
    
    return {
      'count': snapshot.docs.length,
      'interventionsParTechnicien': interventionsParTechnicien,
      'interventionsParEquipement': interventionsParEquipement,
      'interventionsParMois': interventionsParMois,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord statistique'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitFadingCircle(
                color: Colors.blue,
                size: 50.0,
              ),
            );
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          
          final data = snapshot.data!;
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle('Articles'),
                _buildArticlesCharts(data['articles']),
                
                SizedBox(height: 24),
                _buildSectionTitle('Demandes d\'intervention'),
                _buildDemandesCharts(data['demandes']),
                
                SizedBox(height: 24),
                _buildSectionTitle('Équipements'),
                _buildEquipementsCharts(data['equipements']),
                
                SizedBox(height: 24),
                _buildSectionTitle('Rapports de maintenance'),
                _buildMaintenanceCharts(data['maintenances']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildArticlesCharts(Map<String, dynamic> data) {
    final prixDistribution = data['prixDistribution'] as Map<String, int>;
    final prixData = prixDistribution.entries.map((e) => ChartData(e.key, e.value)).toList();
    
    return Column(
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Résumé des articles',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Total', data['count'].toString()),
                    _buildStatCard('Prix moyen', '${data['avgPrix'].toStringAsFixed(2)} €'),
                    _buildStatCard('Prix max', '${data['maxPrix']} €'),
                    _buildStatCard('Prix min', '${data['minPrix']} €'),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Distribution des prix',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Container(
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    series: <CartesianSeries>[
                      ColumnSeries<ChartData, String>(
                        dataSource: prixData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemandesCharts(Map<String, dynamic> data) {
    final statusData = (data['statusDistribution'] as Map<String, int>)
        .entries.map((e) => ChartData(e.key, e.value)).toList();
    final urgenceData = (data['urgenceDistribution'] as Map<String, int>)
        .entries.map((e) => ChartData(e.key, e.value)).toList();
    final technicienData = (data['demandesParTechnicien'] as Map<String, int>)
        .entries.map((e) => ChartData(e.key, e.value)).toList();
    
    return Column(
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Résumé des demandes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                _buildStatCard('Total demandes', data['count'].toString()),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Demandes par statut',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Container(
                  height: 300,
                  child: SfCircularChart(
                    series: <CircularSeries>[
                      PieSeries<ChartData, String>(
                        dataSource: statusData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Demandes par niveau d\'urgence',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Container(
                  height: 300,
                  child: SfCircularChart(
                    series: <CircularSeries>[
                      DoughnutSeries<ChartData, String>(
                        dataSource: urgenceData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Demandes par technicien',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Container(
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    series: <CartesianSeries>[
                      BarSeries<ChartData, String>(
                        dataSource: technicienData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEquipementsCharts(Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Résumé des équipements',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            _buildStatCard('Nombre d\'équipements', data['count'].toString()),
            SizedBox(height: 16),
            Text(
              'Liste des équipements',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (data['equipements'] as List).map((e) => Chip(label: Text(e))).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceCharts(Map<String, dynamic> data) {
    final technicienData = (data['interventionsParTechnicien'] as Map<String, int>)
        .entries.map((e) => ChartData(e.key, e.value)).toList();
    final equipementData = (data['interventionsParEquipement'] as Map<String, int>)
        .entries.map((e) => ChartData(e.key, e.value)).toList();
    final moisData = (data['interventionsParMois'] as Map<String, int>)
        .entries.map((e) => ChartData(e.key, e.value)).toList();
    
    return Column(
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Résumé des maintenances',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                _buildStatCard('Total interventions', data['count'].toString()),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Interventions par mois',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Container(
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    series: <CartesianSeries>[
                      LineSeries<ChartData, String>(
                        dataSource: moisData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                        markerSettings: MarkerSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Interventions par technicien',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Container(
                  height: 300,
                  child: SfCircularChart(
                    series: <CircularSeries>[
                      RadialBarSeries<ChartData, String>(
                        dataSource: technicienData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                        maximumValue: technicienData.fold(0, (max, item) => item.y > max ? item.y : max) * 1.2,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Interventions par équipement',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Container(
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    series: <CartesianSeries>[
                      BarSeries<ChartData, String>(
                        dataSource: equipementData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class ChartData {
  final String x;
  final int y;

  ChartData(this.x, this.y);
}