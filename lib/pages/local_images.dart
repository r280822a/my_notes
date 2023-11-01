import 'package:flutter/material.dart';
import 'dart:io';
import 'package:my_notes/widgets/loading_pages/loading_local_images.dart';
import 'package:my_notes/widgets/delete_alert_dialog.dart';
import 'package:my_notes/widgets/frosted.dart';
import 'package:my_notes/utils/common.dart';

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
    // Get a list of image files

    // Gets path to images
    final String path = await Common.getLocalImagesPath();
    // Stores list of image files
    images = Directory(path).listSync();

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    // If no images, then display loading screen
    if (images.isNotEmpty) {loading = false;} else {loading = true;}
    if (loading){return const LoadingLocalImages();}

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // For frosted look
        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withAlpha(190),
        scrolledUnderElevation: 0,
        flexibleSpace: Frosted(child: Container(color: Colors.transparent)),

        title: const Text("Local Image Attachments"),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
          fontWeight: FontWeight.bold,
          fontSize: 23,
        ),
      ),

      body: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final List<String> imagePathList = images[index].path.split("/");
          final String imageName = imagePathList.last;

          return Column(
            children: [
              Row(
                children: [
                  // Image
                  GestureDetector(
                    onTap: () {
                      // Displays full image when tapped
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(0),
                          child: InteractiveViewer(
                            // To zoom into image
                            maxScale: 5,
                            clipBehavior: Clip.none,
                            child: Image.file(
                              File(images[index].path),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Image.file(
                      File(images[index].path),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Image file name
                  Expanded(
                    child: Text(
                      imageName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  // Button to delete image
                  IconButton(
                    tooltip: "Delete image",
                    onPressed: () {
                      showDialog(
                        context: context, 
                        builder:(context) => DeleteAlertDialog(
                          item: "image",
                          deleteFunction: () {
                            // Delete image file
                            File imageFile = File(images[index].path);
                            if (imageFile.existsSync()){
                              imageFile.deleteSync();
                            }
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