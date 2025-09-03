import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_app/shared/models/song_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfPage extends StatefulWidget {
  final List<SongModel> songs;

  const PdfPage({super.key, required this.songs});

  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  void generatePDF(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'Music Library',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          ...widget.songs.map((song) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Title: ${song.title}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Artist: ${song.artist}'),
                pw.Text('Album: ${song.album}'),
                if (song.lyrics.isNotEmpty) pw.Text('Lyrics: ${song.lyrics}'),
                pw.Text('Path: ${song.path}'),
              ],
            ),
          )),
        ],
      ),
    );

    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Documents/Invoices');
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
        directory = Directory('${directory.path}/Invoices');
      }

      if (!await directory!.exists()) {
        await directory.create(recursive: true);
      }

      final file = File('${directory.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invoice saved to ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving PDF: $e')),
      );
    }

    // await Printing.layoutPdf(
    //   onLayout: (format) {
    //     return pdf.save();
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        generatePDF(context);
      },
      icon: Icon(Icons.print),
    );
  }
}
