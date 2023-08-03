import 'package:example_app/database/todo_db.dart';
import 'package:example_app/widget/e_todo_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:example_app/model/todo.dart';
import 'package:intl/intl.dart';

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  Future<List<Todo>>? futureTodos;
  final todoDB = TodoDB();

  @override
  void initState() {
    super.initState();
    insertInitialData();
    //sleep(const Duration(seconds: 1)); //wait for initial data
    fetchTodos();
  }

  void fetchTodos() {
    setState(() {
      futureTodos = todoDB.fetchAll();
    });
  }

  void insertInitialData() async {
    await todoDB.insertInitialDataFromCSV();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final drawerHeader = UserAccountsDrawerHeader(
      accountName: Text(
        "Jhonatan Ibanez",
      ),
      accountEmail: Text(
        "jhonatan.ibatac@gmail.com",
      ),
      currentAccountPicture: const CircleAvatar(
        child: FlutterLogo(size: 42.0),
        //backgroundImage: AssetImage('assets/teQuieroMucho.jpg'),
      ),
    );

    final drawerItems = ListView(
      children: [
        drawerHeader,
        ListTile(
          title: Text(
            "Export",
          ),
          leading: const Icon(Icons.import_export),
          onTap: () {
            getCsv();
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Todos exported!!")));
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text(
            "Infographic",
          ),
          leading: const Icon(Icons.photo),
          onTap: () async {
            await showDialog(
              context: context,
              builder: (_) => Dialog(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/teQuieroMucho.jpg'),
                          fit: BoxFit.fill)),
                ),
              ),
            );
            //Navigator.pop(context);
          },
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ToDo List'),
      ),
      drawer: Drawer(
        child: drawerItems,
      ),
      body: FutureBuilder<List<Todo>>(
        future: futureTodos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            final todos = snapshot.data!;

            return todos.isEmpty
                ? const Center(
                    child: Text(
                      'No todos ...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  )
                : ListView.separated(
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      final subtitle = DateFormat('yyyy/MM/dd').format(
                          DateTime.parse(todo.updatedAt ?? todo.createdAt));

                      return Card(
                        color: theme.colorScheme.onSecondary,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(
                              todo.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(subtitle),
                            trailing: IconButton(
                              onPressed: () async {
                                await todoDB.delete(todo.id);
                                fetchTodos();
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => CreateTodoWidget(
                                  todo: todo,
                                  onSubmit: (title) async {
                                    await todoDB.update(
                                        id: todo.id, title: title);
                                    fetchTodos();
                                    if (!mounted) return;
                                    Navigator.of(context).pop();
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => CreateTodoWidget(onSubmit: (title) async {
              await todoDB.create(title: title);
              if (!mounted) return;
              fetchTodos();
              Navigator.of(context).pop();
            }),
          );
        },
      ),
    );
  }

  getCsv() async {
    List<Todo> todos = await todoDB.fetchAll();
    List<List<dynamic>> exportData = List<List<dynamic>>.empty(growable: true);

    //Headers
    List<dynamic> headers = List.empty(growable: true);
    headers.add("id");
    headers.add("title");
    headers.add("createdAt");
    headers.add("updatedAt");
    exportData.add(headers);

    for (var todo in todos) {
      List<dynamic> row = List.empty(growable: true);
      row.add(todo.id);
      row.add(todo.title);
      row.add(todo.createdAt);
      row.add(todo.updatedAt);
      exportData.add(row);
    }

    if (await Permission.storage.request().isGranted) {
      //store file in documents folder

      //TODO no use external directories like Downloads
      //TODO update to ios SO
      //final file = await _localFile;
      final file = File('/storage/emulated/0/Download/todos_export.csv');

      // convert rows to String and write as csv file
      String csv = const ListToCsvConverter().convert(exportData);
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
