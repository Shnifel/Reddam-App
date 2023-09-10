import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class ImageUploads extends StatefulWidget {
  final Function(File?) onChange;
  final File? photo;
  const ImageUploads({required this.onChange, Key? key, File? this.photo})
      : super(key: key);

  @override
  _ImageUploadsState createState() => _ImageUploadsState();
}

class _ImageUploadsState extends State<ImageUploads> {
  FirebaseStorage storage = FirebaseStorage.instance;
  File? _photo;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _photo = widget.photo;
  }

  // This is called if the user decides to select a photo from their gallery
  Future imgFromGallery(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color.fromARGB(255, 123, 11, 24),
            content: Text("No image selected", textAlign: TextAlign.center),
          ),
        );
      }
    });
    widget.onChange(_photo);
  }

  // This is called if the user decides to take a photo
  Future imgFromCamera(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color.fromARGB(255, 123, 11, 24),
            content: Text("No image selected", textAlign: TextAlign.center),
          ),
        );
      }
    });
    widget.onChange(_photo);
  }

  // Upload the file to firebase storage
  Future uploadFile(BuildContext context) async {
    if (_photo == null) return;
    final fileName = basename(_photo!.path);
    final destination = 'files/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination).child('file/');
      await ref.putFile(_photo!);
      print(await ref.getDownloadURL());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromARGB(255, 123, 11, 24),
          content: Text("An error occurred", textAlign: TextAlign.center),
        ),
      );
    }
  }

  // Extract given data
  File? getPhoto() {
    return _photo;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            _showPicker(context);
          },
          child: Container(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              width: 150,
              height: 150,
              child: Icon(
                Icons.camera_alt,
                color: Colors.grey[800],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Allow the user to select whether they will take a photo or select an existing photo
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      imgFromGallery(context);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    imgFromCamera(context);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }
}
