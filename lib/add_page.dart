import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: ListView(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'title'),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(hintText: 'Description'),
            minLines: 5,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(
            height: 10.0,
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateColor.resolveWith((states) => Colors.blue),
            ),
            onPressed: submit,
            child: const Text(
              'submit',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> submit() async {
    //Get the data from form
    final title = titleController.text;
    final description = descriptionController.text;

    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    // submit data to the server
    var url = "https://api.nstack.in/v1/todos";
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {"Content-Type": 'application/json'},
    );
    // show success or fail message based on state
    if (response.statusCode == 201) {
      //reset the form after successfull submission

      titleController.text = '';
      descriptionController.text = '';

      showSuccessMessage('Creation Success');
    } else {
      showErrorMessage("Creation failed");
    }
  }

  void showSuccessMessage(String message) {
    final snackbar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
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
}
