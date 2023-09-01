import 'package:flutter/material.dart';
import 'package:my_notes/main.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void addNote(){
    setState(() {
      notes.add(["",""]);
    });
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
            return Padding(
              padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    "/note",
                    arguments: index,
                  );
                  setState(() {});
                },
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.all(10.0),
                    child: Text(notes[index][0])
                  )
                ),
              ),
            );
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


class Note1 extends StatelessWidget {
  const Note1({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Container(
          height: 100,
          width: 100,
          padding: const EdgeInsets.all(10.0),
          child: EditableText(
            focusNode: FocusNode(),
            controller: TextEditingController(),
            backgroundCursorColor: Colors.black,
            cursorColor: Colors.blue,
            
            maxLines: null,
            textAlign: TextAlign.start,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18.0,
            ),
          ),
        )
      ),
    );
  }
}
