import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

class DataExporter {
  static Future<String> getExternalDocumentPath() async {
    // To check whether permission is given for this app or not.
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      // If not we will ask for permission first
      await Permission.manageExternalStorage.request();
    }
    Directory _directory = Directory("");
    if (Platform.isAndroid) {
      // Redirects it to download folder in android
      _directory = Directory("/storage/emulated/0/Download");
    } else {
      _directory = await getApplicationDocumentsDirectory();
    }

    final exPath = _directory.path;
    print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  List<Map<String, dynamic>> data;

  DataExporter(this.data);

  Future<String> writeExcel() async {
    var excel = Excel.createExcel();

    // Create a sheet
    var sheet = excel['Sheet1'];

    // Add headers
    var headers = data[0].keys.toList();
    for (var i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = headers[i];
    }

    // Add data
    for (var i = 0; i < data.length; i++) {
      var rowData = data[i].values.toList();
      for (var j = 0; j < rowData.length; j++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
            .value = rowData[j];
      }
    }

    var directory = await getExternalDocumentPath();
    var filePath = '$directory/excel_data.xlsx';
    List<int>? dataFile = excel.encode();
    var status = await Permission.manageExternalStorage.request();
    if (status.isDenied) {
      // Handle permission denied
      return "";
    }

    await File(filePath).writeAsBytes(dataFile!);

    // Upload to Firebase Storage
    // final ref = FirebaseStorage.instance.ref(
    //     'uploads/excel_spread.xlsx'); // Change 'uploads/' to your desired storage path

    // await ref.putFile(File(filePath));

    // // Get the download URL
    // String downloadURL = await ref.getDownloadURL();

    return filePath; // Return the download URL
  }

  Future<void> writePdf() async {
    final pdf = pw.Document();

    // Add a page
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table(
          children: [
            pw.TableRow(
              children: data[0].keys.map((header) => pw.Text(header)).toList(),
            ),
            ...data.map(
              (row) => pw.TableRow(
                children: row.values.map((item) => pw.Text('$item')).toList(),
              ),
            ),
          ],
        ),
      ),
    );

    // Save the file
    final file = await getExternalStorageDirectory();
    final filePath = '${file!.path}/data.pdf';
    await File(filePath).writeAsBytes(await pdf.save());
  }
}
