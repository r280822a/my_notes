import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:my_notes/widgets/loading_pages/loading_local_images.dart';
import 'package:my_notes/widgets/delete_alert_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class LocalImages extends StatefulWidget {
  const LocalImages({super.key});

  @override
  State<LocalImages> createState() => _LocalImagesState();
}

class _LocalImagesState extends State<LocalImages> {
  bool loading = true;
  List<FileSystemEntity> images = [];

  @override
  void initState() {
    super.initState();
    getImages();
  }

  void getImages() async {
    // Gets a list of image files

    // Gets path to images
    Directory docDir = await getApplicationDocumentsDirectory();
    String docPath = docDir.path.toString();
    String path = p.join(docPath, "assets");
    await Directory(path).create(recursive: true);

    // Stores list of image files
    images = Directory(path).listSync();

    loading = false;
    setState(() {});
  }
  

  @override
  Widget build(BuildContext context) {
    if (loading == true){return const LoadingLocalImages();}

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withAlpha(190),
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.transparent),
          ),
        ),

        title: const Text("Local Image Attachments"),
      ),

      body: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: images.length,
        itemBuilder: (context, index) {
          List<String> imagePathList = images[index].path.split("/");
          String imageName = imagePathList.last;

          return Column(
            children: [
              Row(
                children: [
                  // Image
                  Image.file(
                    File(images[index].path),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover
                  ),
                  const SizedBox(width: 10),
                  // Image name
                  Expanded(
                    child: Text(
                      imageName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  // Button to delete images
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context, 
                        builder:(context) => DeleteAlertDialog(
                          item: "image",
                          deleteFunction: () {
                            File(images[index].path).deleteSync();
                            getImages();
                          }
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red[600],
                  ),
                ],
              ),
              const Divider(height: 2),
            ],
          );
        }
      ),
    );
  }
}