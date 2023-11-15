import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:flutter/material.dart';

class GalleryPage extends StatefulWidget {
  final bool showHeading;
  const GalleryPage({this.showHeading = true, super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  bool isLoading = true;
  List<String> imageUrls = [];

  Future<void> loadGalleryImages() async {
    await FirestoreService.getGalleryImages().then((value) => setState(
          () {
            imageUrls = value;
            isLoading = false;
          },
        ));
  }

  @override
  void initState() {
    super.initState();
    loadGalleryImages();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator(color: primaryColour))
        : Padding(
            padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
            child: Column(
              children: [
                if (widget.showHeading)
                  Container(
                      alignment: Alignment.centerLeft,
                      child: Text('Gallery',
                          style: loginPageText.copyWith(
                              fontSize: 35, fontWeight: FontWeight.bold))),
                Expanded(
                    child: GridView.builder(
                        padding: EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            child: Image.network(
                              imageUrls[index],
                              loadingBuilder:
                                  (context, child, loadingProgress) =>
                                      (loadingProgress == null)
                                          ? child
                                          : const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  color: primaryColour,
                                                )
                                              ],
                                            ),
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Text("Image not found")),
                              width: 100,
                              height: 100,
                              fit: BoxFit.fitHeight,
                            ),
                          );
                        })),
              ],
            ),
          );
  }
}
