import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

class DataExporter {
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
    var directory;
    bool dirDownloadExists = true;
    if (Platform.isIOS) {
      directory = await getDownloadsDirectory();
    } else {
      directory = "/storage/emulated/0/Download/";

      dirDownloadExists = await Directory(directory).exists();
      if (dirDownloadExists) {
        directory = "/storage/emulated/0/Download/";
      } else {
        directory = "/storage/emulated/0/Downloads/";
      }
    }

    // Save the file

    var filePath = '$directory/data.xlsx';
    print(filePath);
    List<int>? dataFile = excel.encode();
    File(filePath).writeAsBytes(dataFile!);

    return filePath;
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
