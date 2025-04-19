import 'package:flutter/material.dart';
import 'package:untitled/common/color_extension.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<String> _allItems = [
    "Apple",
    "Banana",
    "Cherry",
    "Date",
    "Grapes",
    "Mango",
    "Orange",
    "Pineapple",
    "Strawberry",
    "Watermelon"
  ];

  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems; // Initially show all items
  }

  void _filterSearchResults(String query) {
    setState(() {
      _filteredItems = _allItems
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.back,
      // appBar: AppBar(title: const Text("Search")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40,),



            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Search",
                  style: TextStyle(color: TColor.gray80, fontSize: 16),
                )
              ],
            ),
            const SizedBox(height: 40,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey, width: 1), // Custom border
                color: Colors.white, // Background color (optional)
              ),
              child: TextField(
                onChanged: _filterSearchResults,
                decoration: const InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none, // No default border
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredItems.isNotEmpty
                  ? ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_filteredItems[index]),
                    leading: const Icon(Icons.check_circle_outline),
                  );
                },
              )
                  : const Center(
                child: Text(
                  "No results found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}