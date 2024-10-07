import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PaginatedListScreen(),
    );
  }
}

class PaginatedListScreen extends StatefulWidget {
  const PaginatedListScreen({Key? key}) : super(key: key);

  @override
  State<PaginatedListScreen> createState() => _PaginatedListScreenState();
}

class _PaginatedListScreenState extends State<PaginatedListScreen> {
  List<Map<String, dynamic>> items = [];
  int currentPage = 1;
  bool isLoading = false;

  // Backend server URL
  // http://10.0.2.2:8080 for Android emulator  
  final String backendUrl = 'http://127.0.0.1:8080/items';  // for chrome web

  Future<List<Map<String, dynamic>>> _fetchData(int page) async {
    final response = await http.get(
      Uri.parse('$backendUrl?page=$page'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['items']);
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<void> _loadItems(int page) async {
    if (isLoading) return; // Prevent multiple simultaneous requests

    setState(() {
      isLoading = true;
    });

    try {
      final fetchedItems = await _fetchData(page);
      setState(() {
        items.addAll(fetchedItems);
      });
    } catch (e) {
      print('Error fetching items: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadItems(currentPage); // Load initial items
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: InfiniteList(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]['name']),
                );
              },
              onFetchData: () async {
                if (!isLoading) {
                  currentPage++;
                  await _loadItems(currentPage); 
                }
              },
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
