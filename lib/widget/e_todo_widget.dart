import 'package:example_app/model/todo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateTodoWidget extends StatefulWidget {
  final Todo? todo;
  final ValueChanged<String> onSubmit;
  const CreateTodoWidget({
    Key? key,
    this.todo,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<CreateTodoWidget> createState() => _CreateTodoWidgetState();
}

class _CreateTodoWidgetState extends State<CreateTodoWidget> {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller.text = widget.todo?.title ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todo != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Todo' : 'Add Todo'),
      content: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              autofocus: true,
              controller: controller,
              decoration: const InputDecoration(hintText: 'Title'),
              validator: (value) =>
                  value != null && value.isEmpty ? 'Title is required' : null,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                color: Colors.green,
                height: 50,
                child: TextButton(
                  child: Text(
                    "Export to CSV",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: getCsv,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              widget.onSubmit(controller.text);
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  getCsv() async {
    List<List<dynamic>> employeeData =
        List<List<dynamic>>.empty(growable: true);
    for (int i = 0; i < 5; i++) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      List<dynamic> row = List.empty(growable: true);
      row.add("Employee Name $i");
      row.add((i % 2 == 0) ? "Male" : "Female");
      row.add(" Experience : ${i * 5}");
      employeeData.add(row);
    }

    //TODO replace employee with full data of todos
    //Use the export button in a DrawerHEader

    if (await Permission.storage.request().isGranted) {
      //store file in documents folder

      //TODO no use external directories like Downloads
      //final file = await _localFile;
      final file = File('/storage/emulated/0/Download/todos_export.csv');

      // convert rows to String and write as csv file
      String csv = const ListToCsvConverter().convert(employeeData);
      file.writeAsString(csv);

      //TODO No work: alternative method to download
      //_launchUrl();
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/todos_export.csv');
  }

  Future<void> _launchUrl() async {
    final Uri _url =
        Uri.parse('file:/storage/emulated/0/Download/todos_export.csv');
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}
