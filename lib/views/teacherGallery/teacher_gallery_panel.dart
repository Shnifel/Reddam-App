import 'package:cce_project/views/student_gallery_page.dart';
import 'package:flutter/material.dart';

class TeacherGalleryPanelPage extends StatefulWidget {
  const TeacherGalleryPanelPage({super.key});

  @override
  State<TeacherGalleryPanelPage> createState() =>
      _TeacherGalleryPanelPageState();
}

class _TeacherGalleryPanelPageState extends State<TeacherGalleryPanelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GalleryPage(
        showHeading: false,
      ),
    );
  }
}
