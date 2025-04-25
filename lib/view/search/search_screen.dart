import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import '../../controller/categoryController.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CategoryController categoryController = Get.find<CategoryController>(); // Get the CategoryController

  List<String> _allItems = []; // To hold all categories
  List<String> _filteredItems = []; // To hold filtered categories

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    // Wait for the fetch operation to complete
    await categoryController.fetchCategory();

    // After fetching is complete, get categories from the controller's categoryList
    setState(() {
      // Convert Category objects to strings, handling null values
      _allItems = categoryController.categoryList
          .map((category) => category.name ?? "Unnamed Category")
          .toList();
      _filteredItems = _allItems;
    });
  }

  // Filter categories based on the search query
  void _filterSearchResults(String query) {
    setState(() {
      _filteredItems = _allItems
          .where((category) => category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.back,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40,),

            // Search title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Search category",
                  style: TextStyle(color: TColor.gray80, fontSize: 16),
                )
              ],
            ),
            const SizedBox(height: 40,),

            // Search bar
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey, width: 1),
                color: Colors.white,
              ),
              child: TextField(
                onChanged: _filterSearchResults,
                decoration: const InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Display the filtered categories
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