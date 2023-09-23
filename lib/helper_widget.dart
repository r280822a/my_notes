import 'package:flutter/material.dart';
import 'package:my_notes/notes_db.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

Scaffold loadingHomeScreen(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      leading: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {},
      ),
    ),

    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,

    body: GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 10,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        mainAxisExtent: 150,
      ),
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          child: Container(),
        );
      },
    ),

    floatingActionButton: FloatingActionButton(
      onPressed: () {},
      tooltip: 'Add note',
      child: const Icon(Icons.add),
    ),
  );
}

Scaffold loadingNoteEditorScreen(BuildContext context){
  return Scaffold(
    appBar: AppBar(
      actions: [
        PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 10),
                  Text("Copy"),
                ],
              )
            ),
            const PopupMenuItem(
              child: Row(
                children: [
                  Icon(Icons.edit_note),
                  SizedBox(width: 10),
                  Text("View raw"),
                ],
              )
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red[600]),
                  const SizedBox(width: 10),
                  const Text("Delete"),
                ],
              )
            ),
          ]
        ),
      ],
    ),


    body: const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display note
          SizedBox(height: 35),
          Divider(),
        ],
      ),
    ),


    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    floatingActionButton: Material(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_box_outlined),
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_photo_alternate_outlined),
            color: Theme.of(context).colorScheme.onBackground,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_photo_alternate, size: 28),
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ],
      ),
    ),
  );
}


SizedBox roundedSquare(double size, Widget child, BuildContext context) {
  return SizedBox(
    // Progress indicator inside square with rounded edges
    height: size,
    width: size,
    child: Stack(
      children: <Widget>[
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.all(Radius.circular(20))
            ),
            child: SizedBox(height: size, width: size)
          ),
        ),
        Center(child: child),
      ],
    ),
  );
}

class RawDescFormField extends StatelessWidget {
  const RawDescFormField({
    super.key,
    required this.note,
    required this.notesDB,
  });

  final Note note;
  final NotesDatabase notesDB;

  @override
  Widget build(BuildContext context) {
    // Builds TextFormField for unrendered description (mainly for testing)
    // Only affects checkboxes
    return TextFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),

      style: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
      maxLines: null,
      initialValue: note.description,
      onChanged: (value) {
        note.description = value;
        notesDB.updateNote(note);
      },
    );
  }
}

class TitleFormField extends StatelessWidget {
  const TitleFormField({
    super.key,
    required this.note,
    required this.notesDB,
  });

  final Note note;
  final NotesDatabase notesDB;

  @override
  Widget build(BuildContext context) {
    // Builds TextFormField for title
    return TextFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),

      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 23,
      ),
      maxLines: 1,
      initialValue: note.title,
      onChanged: (value) {
        note.title = value;
        notesDB.updateNote(note);
      },
    );
  }
}

class DescLocalImage extends StatelessWidget {
  const DescLocalImage({
    super.key,
    required this.path,
    required this.imageName,
    required this.index,
    required this.deleteDescLocalImage,
  });

  final String path;
  final String imageName;
  final int index;
  final Function deleteDescLocalImage;

  @override
  Widget build(BuildContext context) {
    double size = 60;

    return PopupMenuButton(
      position: PopupMenuPosition.under,
      onOpened: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },

      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            deleteDescLocalImage(index, imageName);
          },
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red[600]),
              const SizedBox(width: 10),
              const Text("Delete"),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Image.file(
          File(p.join(path, imageName)),

          errorBuilder: (context, error, stackTrace) {
            // Error icon inside square with rounded edges
            return roundedSquare(size, const Icon(Icons.error), context);
          },
        ),
      ),
    );
  }
}

class DescNetworkImage extends StatelessWidget {
  const DescNetworkImage({
    super.key,
    required this.link,
    required this.index,
    required this.removeDescNetworkImage,
  });

  final String link;
  final int index;
  final Function removeDescNetworkImage;

  @override
  Widget build(BuildContext context) {
    double size = 60;

    return PopupMenuButton(
      position: PopupMenuPosition.under,
      onOpened: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },

      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            removeDescNetworkImage(index);
          },
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red[600]),
              const SizedBox(width: 10),
              const Text("Delete"),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Image.network(
          link,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return roundedSquare(
              // Progress indicator inside square with rounded edges
              size, 
              CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null ? 
                  loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              ),
              context
            );
          },

          errorBuilder: (context, error, stackTrace) {
            // Error icon inside square with rounded edges
            return roundedSquare(size, const Icon(Icons.error), context);
          },
        ),
      ),
    );
  }
}

class DescCheckBox extends StatelessWidget {
  const DescCheckBox({
    super.key,
    required this.textControllers,
    required this.checkboxStr,
    required this.checkboxTickedStr,
    required this.descriptionList,
    required this.note,
    required this.notesDB,
    required this.isTicked,
    required this.index,
    required this.initValue,
    required this.hasMultiLines,
    required this.selectDescCheckBox,
    required this.removeDescCheckBox,
  });

  final List<TextEditingController> textControllers;
  final String checkboxStr;
  final String checkboxTickedStr;
  final List<String> descriptionList;
  final Note note;
  final NotesDatabase notesDB;
  final bool isTicked;
  final int index;
  final String initValue;
  final bool hasMultiLines;
  final Function selectDescCheckBox;
  final Function removeDescCheckBox;

  @override
  Widget build(BuildContext context) {
    // To build checkbox
    return Row(
      children: [
        Checkbox(
          value: isTicked,
          onChanged: (bool? value) {
            selectDescCheckBox(isTicked, index);
          },
        ),
        Flexible(
          child: DescFormField(textControllers: textControllers, checkboxStr: checkboxStr, checkboxTickedStr: checkboxTickedStr, descriptionList: descriptionList, note: note, notesDB: notesDB, index: (descriptionList.length - 1), initValue: initValue, hasMultiLines: false)
        ),
        IconButton(
          onPressed: () {
            removeDescCheckBox(index);
          }, 
          icon: const Icon(Icons.delete_outline)
        )
      ],
    );
  }
}

class DescFormField extends StatelessWidget {
  const DescFormField({
    super.key,
    required this.textControllers,
    required this.checkboxStr,
    required this.checkboxTickedStr,
    required this.descriptionList,
    required this.note,
    required this.notesDB,
    required this.index,
    required this.initValue,
    required this.hasMultiLines,
  });

  final List<TextEditingController> textControllers;
  final String checkboxStr;
  final String checkboxTickedStr;
  final List<String> descriptionList;
  final Note note;
  final NotesDatabase notesDB;
  final int index;
  final String initValue;
  final bool hasMultiLines;

  @override
  Widget build(BuildContext context) {
    // Builds TextFormField for each textblock and checkbox
    return TextFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),

      key: Key(initValue.toString() + index.toString()),
      maxLines: hasMultiLines ? null : 1,
      controller: textControllers[index],

      onChanged: (value) {
        int cbIndex = descriptionList[index].indexOf(checkboxStr);
        int cbTickedIndex = descriptionList[index].indexOf(checkboxTickedStr);

        if (cbIndex == 0) {
          value = "$checkboxStr$value";
        } else if (cbTickedIndex == 0){
          value = "$checkboxTickedStr$value";
        }
        descriptionList[index] = value;
        String newDescription = descriptionList.join("\n");

        note.description = newDescription;
        notesDB.updateNote(note);
      },
    );
  }
}
