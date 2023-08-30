import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Widget> notes = [];

  void addNote(){
    setState(() {});
    notes.add(const Note());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home"),
      ),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (_, index) {
            return notes[index];
          },
        ),
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
  const Note({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: EditableText(
            focusNode: FocusNode(),
            controller: TextEditingController(),
            backgroundCursorColor: Colors.black,
            
            maxLines: null,
            textAlign: TextAlign.start,
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
