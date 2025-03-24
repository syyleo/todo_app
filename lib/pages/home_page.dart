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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isTextBoxVisible = false;
  bool _isFabVisible = true;
  int _selectedIndex = 0;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<List<Object>> toDoList = []; // Explicitly defining the type

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadAppState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      saveAppState();
    }
  }

  void checkBoxChanged(int index) {
    setState(() {
      toDoList[index][1] = !(toDoList[index][1] as bool);
      saveAppState();
    });
  }

  void saveNewTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        toDoList.add([_controller.text, false]);
        _listKey.currentState?.insertItem(toDoList.length - 1);
        _controller.clear();
        _isTextBoxVisible = false;
        _isFabVisible = true;
        saveAppState();
      });
    }
  }

  void deleteTask(int index) {
    setState(() {
      final removedItem = toDoList.removeAt(index);
      _listKey.currentState?.removeItem(index, (context, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: TodoList(
            taskName: removedItem[0] as String,
            taskCompleted: removedItem[1] as bool,
            onChanged: null,
            deleteFunction: null,
          ),
        );
      });
      saveAppState();
    });
  }

  Future<void> loadAppState() async {
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
    String? currentText = prefs.getString('currentText');
    bool? isTextBoxVisible = prefs.getBool('isTextBoxVisible');
    setState(() {
      _controller.text = currentText ?? '';
      _isTextBoxVisible = isTextBoxVisible ?? false;
      _isFabVisible = !_isTextBoxVisible;
      if (_isTextBoxVisible) {
        _focusNode.requestFocus();
      } else {
        _focusNode.unfocus();
      }
    });
  }

  Future<void> saveAppState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasks =
        toDoList.map((task) => '${task[0]},${task[1]}').toList();
    await prefs.setStringList('tasks', tasks);
    await prefs.setString('currentText', _controller.text);
    await prefs.setBool('isTextBoxVisible', _isTextBoxVisible);
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
    saveAppState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isFabVisible = (index == 0); // Show FAB only on the home page
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = <Widget>[
      AnimatedList(
        key: _listKey,
        initialItemCount: toDoList.length,
        itemBuilder: (context, index, animation) {
          return SizeTransition(
            sizeFactor: animation,
            child: TodoList(
              taskName: toDoList[index][0] as String,
              taskCompleted: toDoList[index][1] as bool,
              onChanged: (value) => checkBoxChanged(index),
              deleteFunction: (context) => deleteTask(index),
            ),
          );
        },
      ),
      const CalendarWidget(),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Type Here...',
                          filled: true,
                          fillColor: const Color.fromARGB(255, 37, 39, 95),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 37, 39, 95)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 37, 39, 95)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check),
                      color: Colors.white,
                      onPressed: saveNewTask,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 37, 39, 95),
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
                  color: _selectedIndex == 0
                      ? const Color.fromARGB(255, 37, 39, 95)
                      : Colors.blue,
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
                  color: _selectedIndex == 1
                      ? const Color.fromARGB(255, 37, 39, 95)
                      : Colors.blue,
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
