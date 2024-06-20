import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Parse code
  final keyApplicationId = 'YOUR_APP_ID_HERE';
  final keyClientKey = 'YOUR_CLIENT_KEY_HERE';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);
  //

  runApp(const MaterialApp(home: TodoApp()));
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  List<ParseObject> tasks = [];
  TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getTodo();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.white,
          hintColor: Colors.black,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme:
              AppBarTheme(backgroundColor: Color.fromARGB(255, 68, 122, 246))),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Todo List'),
        ),
        body: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildTaskInput(),
              const SizedBox(height: 20),
              Expanded(child: _buildTaskList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: taskController,
              decoration: InputDecoration(
                hintText: 'Enter tasks',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: addTodo,
            style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.black)),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        //Get Parse Object Values
        final varTodo = tasks[index];
        final varTitle = varTodo.get<String>('title') ?? '';
        bool done = varTodo.get<bool>('done') ?? false;

        return ListTile(
          title: Row(
            children: [
              Checkbox(
                value: done,
                onChanged: (newValue) {
                  updateTodo(index, newValue!);
                },
              ),
              Expanded(child: Text(varTitle)),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              deleteTodo(index, varTodo.objectId!);
            },
          ),
        );
      },
    );
  }

  Future<void> addTodo() async {
    String task = taskController.text.trim();
    if (task.isNotEmpty) {
      // Parse code
      final todo = ParseObject('Todo')
        ..set('title', task)
        ..set('done', false);
      await todo.save();
      //

      setState(() {
        tasks.add(todo);
      });
      taskController.clear();
    }
  }

  Future<void> updateTodo(int index, bool done) async {
    // Parse code
    final varTodo = tasks[index];
    varTodo.set('done', done);
    await varTodo.save();
    //

    setState(() {
      tasks[index] = varTodo;
    });
  }

  Future<List<ParseObject>> getTodo() async {
    // Parse code
    QueryBuilder<ParseObject> queryTodo =
        QueryBuilder<ParseObject>(ParseObject('Todo'));
    final ParseResponse apiResponse = await queryTodo.query();
    //

    if (apiResponse.success && apiResponse.results != null) {
      setState(() {
        tasks = apiResponse.results as List<ParseObject>;
      });
      return tasks;
    } else {
      return [];
    }
  }

  Future<void> deleteTodo(int index, String id) async {
    // Parse code
    final varTodo = tasks[index];
    await varTodo.delete();
    //

    setState(() {
      tasks.removeAt(index);
    });
  }
}
