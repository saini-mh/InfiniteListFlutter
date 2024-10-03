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
  final int itemsPerPage = 5;
  bool isLoading = false;
  int totalItems = 0;

  // Backend server URL
  // http://10.0.2.2:8080 for Android emulator  
  final String backendUrl = 'http://127.0.0.1:8080/items';  // for chrome web

  Future<Map<String, dynamic>> _fetchData(int page) async {
    final response = await http.get(
      Uri.parse('$backendUrl?page=$page&page_size=$itemsPerPage'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'items': List<Map<String, dynamic>>.from(data['items']),
        'totalItems': data['total'],
      };
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
      final fetchedData = await _fetchData(page);
      setState(() {
        items = fetchedData['items'];
        totalItems = fetchedData['totalItems'];
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

  int get totalPages => (totalItems / itemsPerPage).ceil();

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
                if (!isLoading && currentPage < totalPages) {
                  await _loadItems(currentPage); 
                }
              },
              isLoading: isLoading,
            ),
          ),
          // Pagination controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: currentPage > 1
                    ? () {
                        setState(() {
                          currentPage = 1; // Go to the first page
                        });
                        _loadItems(currentPage);
                      }
                    : null,
                child: const Text('First'),
              ),
              ElevatedButton(
                onPressed: currentPage > 1
                    ? () {
                        setState(() {
                          currentPage--; // Go to the previous page
                        });
                        _loadItems(currentPage);
                      }
                    : null,
                child: const Text('Previous'),
              ),
              ElevatedButton(
                onPressed: currentPage < totalPages
                    ? () {
                        setState(() {
                          currentPage++; // Go to the next page
                        });
                        _loadItems(currentPage);
                      }
                    : null,
                child: const Text('Next'),
              ),
              ElevatedButton(
                onPressed: currentPage < totalPages
                    ? () {
                        setState(() {
                          currentPage = totalPages; // Go to the last page
                        });
                        _loadItems(currentPage);
                      }
                    : null,
                child: const Text('Last'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Page $currentPage of $totalPages'),
          ),
        ],
      ),
    );
  }
}
