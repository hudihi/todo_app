import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/add_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo'),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                'No Todo Item',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            child: ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final id = item['_id'] as String;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(item['title']),
                      subtitle: Text(item['description']),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == "edit") {
                            //Open Edit page
                            navigateToEditPage(item);
                          } else if (value == "delete") {
                            // Delete and remove the item
                            deleteById(id);
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text("Edit"),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text("Delete"),
                            ),
                          ];
                        },
                      ),
                    ),
                  );
                }),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: const Text("Add Todo"),
      ),
    );
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(),
    );
    await Navigator.push(
      context,
      route,
    );
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    // delete the item
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    // remove item from list
    if (response.statusCode == 200) {
      final filtered = items.where((element) => element["_id"] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      showErrorMessage('deletion is fail');
    }
  }

  Future<void> fetchTodo() async {
    var url = "https://api.nstack.in/v1/todos?page=1&limit=10";
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map;
      final result = jsonData['items'] as List;
      setState(() {
        items = result;
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorMessage(String message) {
    final snackbar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: ((context) => AddTodoPage(todo: item)),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }
}
