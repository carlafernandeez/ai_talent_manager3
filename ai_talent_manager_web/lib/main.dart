import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Talent Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFEAF2F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D47A1),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Color(0xFF0D47A1)),
        ),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF1565C0),
          secondary: const Color(0xFF90CAF9),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List employees = [];
  int _selectedIndex = 0;
  bool _showAllEmployees = false;

  final List<String> fakeNames = [
    'Annette Black', 'Daniel Howard', 'Janet Jones', 'Cody Vicker', 'Kristin Vickson',
    'Michael Johnson', 'Laura Smith', 'Kevin Brown', 'Emily Davis', 'Brian Wilson',
    'Alice Moore', 'James Taylor', 'Olivia Martin', 'John Walker', 'Grace Lewis',
    'Ethan Young', 'Lily Hall', 'Aiden Allen', 'Zoe King', 'Luke Scott'
  ];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    final response = await http.get(Uri.parse('http://localhost:8000/employees'));
    if (response.statusCode == 200) {
      setState(() {
        employees = json.decode(response.body);
      });
    } else {
      throw Exception("No s'han pogut carregar els empleats");
    }
  }

  String getEmoji(int value) {
    if (value >= 4) return '😄';
    if (value == 3) return '🙂';
    if (value == 2) return '😐';
    return '😟';
  }

  Widget _buildCard(String title, Widget child, double width) {
    return SizedBox(
      width: width,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeOverview() {
    final list = _showAllEmployees ? employees : employees.take(5).toList();
    return Column(
      children: [
        ...list.asMap().entries.map((entry) {
          final idx = entry.key;
          final emp = entry.value;
          final name = idx < fakeNames.length ? fakeNames[idx] : 'Employee ${idx + 1}';
          final performance = (emp['PerformanceRating'] ?? 3);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(flex: 2, child: Text(name, style: const TextStyle(fontSize: 16))),
                Expanded(flex: 2, child: Text(emp['JobRole'] ?? '', style: const TextStyle(fontSize: 16))),
                Expanded(flex: 1, child: Text(getEmoji(emp['JobSatisfaction'] ?? 3), style: const TextStyle(fontSize: 16))),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: performance / 4.0,
                    backgroundColor: Colors.blue[50],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              setState(() {
                _showAllEmployees = !_showAllEmployees;
              });
            },
            child: Text(_showAllEmployees ? 'Veure menys' : 'Veure més'),
          ),
        )
      ],
    );
  }

  Widget _buildObjectiveCompletion() {
    double globalProgress = employees.isNotEmpty
        ? employees.map((e) => e['PerformanceRating'] ?? 3).reduce((a, b) => a + b) / (employees.length * 4)
        : 0.5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: globalProgress,
          minHeight: 16,
          backgroundColor: Colors.blue[50],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
        ),
        const SizedBox(height: 8),
        Text("Total: ${(globalProgress * 100).round()}%", style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildDashboardView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            _buildCard('Employee Overview', _buildEmployeeOverview(), double.infinity),
            const SizedBox(height: 16),
            _buildCard("Compliment global d'objectius", _buildObjectiveCompletion(), double.infinity),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCard('Objectius recents', _buildRecentObjectives(), double.infinity)),
                const SizedBox(width: 32),
                Expanded(child: _buildCard('▸ Alertes prioritàries', _buildPriorityAlerts(), double.infinity)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentObjectives() {
    final List<Map<String, dynamic>> enterpriseObjectives = [
      {'name': 'Millorar la fiabilitat del sistema', 'progress': 0.76},
      {'name': 'Mentorar enginyers júnior', 'progress': 1.0},
      {'name': 'Reduir el deute tècnic', 'progress': 0.4},
    ];

    return Column(
      children: enterpriseObjectives.map((obj) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(obj['name'], style: const TextStyle(fontSize: 15)),
                  Text("${(obj['progress'] * 100).round()}%", style: const TextStyle(fontSize: 15)),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: obj['progress'],
                minHeight: 6,
                backgroundColor: Colors.blue[100],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriorityAlerts() {
    final alerts = employees.where((e) {
      return (e['Attrition'] == 'Yes') ||
          ((e['PerformanceRating'] ?? 3) < 2) ||
          ((e['JobSatisfaction'] ?? 3) <= 2 && (e['PerformanceRating'] ?? 3) <= 2);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: alerts.map((e) {
        final idx = employees.indexOf(e);
        final name = idx < fakeNames.length ? fakeNames[idx] : 'Employee ${idx + 1}';
        final reasons = <String>[];
        if (e['Attrition'] == 'Yes') reasons.add('Risc de rotació alt');
        if ((e['PerformanceRating'] ?? 3) < 2) reasons.add('Objectius incomplerts');
        if ((e['PerformanceRating'] ?? 3) <= 2 && (e['JobSatisfaction'] ?? 3) <= 2) reasons.add('Baix rendiment mantingut');

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('⚠️ $name: ${reasons.join(', ')}', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 4;
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: Colors.blue[100],
                ),
                child: const Text('Enviar missatge'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChatPage() {
    return const Center(child: Text("Xat amb empleats (simulat)"));
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Text(
        '$title Page (en construcció)',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboardView(),
      _buildPlaceholder('Performance'),
      _buildPlaceholder('Development'),
      _buildPlaceholder('Wellbeing'),
      _buildChatPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Talent Manager'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Performance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Development',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wellbeing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Xat',
          ),
        ],
      ),
    );
  }
}
