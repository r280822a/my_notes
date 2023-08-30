import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Widget> notes = [];

  void addNote(){
    setState(() {});
    notes.add(Note());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (_, index) {
          return notes[index];
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        tooltip: 'Add note',
        child: const Icon(Icons.add),
      ),
    );
  }
}


class Note extends StatelessWidget {
  final TextEditingController noteText = TextEditingController();

  Note({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: EditableText(
            maxLines: null,
            backgroundCursorColor: Colors.black,
            textAlign: TextAlign.start,
            focusNode: FocusNode(),
            controller: TextEditingController(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18.0,
            ),
            keyboardType: TextInputType.multiline,
            cursorColor: Colors.blue,
          ),
        )
      ),
    );
  }
}