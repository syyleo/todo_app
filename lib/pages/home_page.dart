import 'package:flutter/material.dart';
import 'package:app/utils/todo_list.dart';
import 'package:app/pages/profile_page.dart';
import 'package:app/utils/calendar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isTextBoxVisible = false;
  bool _isFabVisible = true;
  int _selectedIndex = 0;
  List<List<dynamic>> toDoList = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void checkBoxChanged(int index) {
    setState(() {
      toDoList[index][1] = !toDoList[index][1];
      saveTasks();
    });
  }

  void saveNewTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        toDoList.add([_controller.text, false]);
        _controller.clear();
        _isTextBoxVisible = false;
        _isFabVisible = true;
        saveTasks();
      });
    }
  }

  void deleteTask(int index) {
    setState(() {
      toDoList.removeAt(index);
      saveTasks();
    });
  }

  Future<void> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? tasks = prefs.getStringList('tasks');
    if (tasks != null) {
      setState(() {
        toDoList = tasks.map((item) {
          List<String> task = item.split(',');
          return [task[0], task[1] == 'true'];
        }).toList();
      });
    }
  }

  Future<void> saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasks =
        toDoList.map((task) => '${task[0]},${task[1]}').toList();
    await prefs.setStringList('tasks', tasks);
  }

  void toggleTextBoxVisibility() {
    setState(() {
      _isTextBoxVisible = !_isTextBoxVisible;
      _isFabVisible = !_isTextBoxVisible;
      if (_isTextBoxVisible) {
        _focusNode.requestFocus();
      } else {
        _focusNode.unfocus();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isFabVisible = (index == 0); // Show FAB only on the home page
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = <Widget>[
      ListView.builder(
        itemCount: toDoList.length,
        itemBuilder: (BuildContext context, index) {
          return TodoList(
            taskName: toDoList[index][0],
            taskCompleted: toDoList[index][1],
            onChanged: (value) => checkBoxChanged(index),
            deleteFunction: (context) => deleteTask(index),
          );
        },
      ),
      const CalendarWidget(), // Calendar widget
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 60),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 90),
        title: const Text('Home'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            iconSize: 36,
            color: Colors.blue,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: widgetOptions.elementAt(_selectedIndex),
          ),
          if (_isTextBoxVisible)
            Positioned(
              bottom: 10,
              left: -15,
              right: -15,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onSubmitted: (value) {
                    saveNewTask();
                  },
                  decoration: InputDecoration(
                    hintText: 'Type Here...',
                    filled: true,
                    fillColor: Colors.deepPurple,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              onPressed: toggleTextBoxVisibility,
              elevation: 6.0,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        color: const Color.fromARGB(255, 0, 0, 90),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.task_alt_rounded),
                  color: _selectedIndex == 0 ? Colors.deepPurple : Colors.blue,
                  onPressed: () => _onItemTapped(0),
                  iconSize: 36.0,
                ),
              ],
            ),
            const SizedBox(width: 50),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  color: _selectedIndex == 1 ? Colors.deepPurple : Colors.blue,
                  onPressed: () => _onItemTapped(1),
                  iconSize: 36.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
