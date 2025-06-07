import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/common/color_extension.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  final TextEditingController _searchController = TextEditingController();

  List<String> allUsers = [];
  List<String> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();

    _searchController.addListener(() {
      filterUsers(_searchController.text);
    });
  }

Future<void> fetchUsers() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
 print('Fetched ${snapshot.docs.length} users ======================');
    final names = snapshot.docs.map((doc) {
      final data = doc.data();
      return data['name']?.toString() ?? '';
    }).where((name) => name.isNotEmpty).toList();

    setState(() {
      allUsers = names;
      filteredUsers = names;
    });
  } catch (e) {
    debugPrint('Error fetching users: $e');
  }
}


  void filterUsers(String query) {
    final result = allUsers
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      filteredUsers = result;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.back,
        title: Text('User List',style: TextStyle(color: TColor.gray80),),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text("No users found."))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredUsers[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
