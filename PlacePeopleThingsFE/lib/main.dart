import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

// Use --dart-define=API_BASE=https://api.example.com to override when running
const apiBase = String.fromEnvironment('API_BASE', defaultValue: 'http://localhost:3000');

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlacePeopleThings',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> places = [];
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await http.get(Uri.parse('$apiBase/api/places')).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        setState(() {
          places = jsonDecode(res.body) as List<dynamic>;
        });
      } else {
        setState(() {
          error = 'API error: ${res.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Request failed: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Places')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : error != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text(error!), const SizedBox(height: 8), ElevatedButton(onPressed: _loadPlaces, child: const Text('Retry'))],
                  )
                : RefreshIndicator(
                    onRefresh: _loadPlaces,
                    child: ListView.builder(
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        final p = places[index] as Map<String, dynamic>;
                        return ListTile(
                          title: Text(p['name'] ?? 'No name'),
                          subtitle: Text(p['description'] ?? ''),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadPlaces,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

