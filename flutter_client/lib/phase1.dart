import 'package:flutter/material.dart';
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
  final List<String> items = List.generate(50, (index) => 'Item ${index + 1}');
  int currentPage = 0;
  final int itemsPerPage = 5;

  // Calculate total pages
  int get totalPages => (items.length / itemsPerPage).ceil();

  // Simulate fetching data (since we already have data in this case)
  Future<void> _onFetchData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Get the current 5 items to display on the current page
    final paginatedItems = items.skip(currentPage * itemsPerPage).take(itemsPerPage).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: InfiniteList(
              itemCount: paginatedItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(paginatedItems[index]),
                );
              },
              onFetchData: _onFetchData,
              isLoading: false,
            ),
          ),
          // Pagination controls: First, Previous, Next, Last buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: currentPage > 0
                    ? () {
                        setState(() {
                          currentPage = 0;
                        });
                      }
                    : null,
                child: const Text('First'),
              ),
              ElevatedButton(
                onPressed: currentPage > 0
                    ? () {
                        setState(() {
                          currentPage--;
                        });
                      }
                    : null,
                child: const Text('Previous'),
              ),
              ElevatedButton(
                onPressed: (currentPage + 1) * itemsPerPage < items.length
                    ? () {
                        setState(() {
                          currentPage++;
                        });
                      }
                    : null,
                child: const Text('Next'),
              ),
              ElevatedButton(
                onPressed: (currentPage + 1) * itemsPerPage < items.length
                    ? () {
                        setState(() {
                          currentPage = (items.length / itemsPerPage).ceil() - 1;
                        });
                      }
                    : null,
                child: const Text('Last'),
              ),
            ],
          ),
          // Display the current page out of total pages
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Page ${currentPage + 1} of $totalPages'),
          ),
        ],
      ),
    );
  }
}