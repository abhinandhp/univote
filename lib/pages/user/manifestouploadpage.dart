import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univote/pages/userelctiondetails.dart';

class ManifestoUploadPage extends StatefulWidget {
  final Map<String, dynamic> profile;
  final Map<String, dynamic> elec;

  const ManifestoUploadPage({
    super.key,
    required this.profile,
    required this.elec,
  });

  @override
  State<ManifestoUploadPage> createState() => _ManifestoUploadPageState();
}

class _ManifestoUploadPageState extends State<ManifestoUploadPage> {
  bool pdfUploaded = false;
  String? uploadedPdfUrl;

  final client = Supabase.instance.client;

  Future<void> pickAndUploadPDF() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final name = result.files.single.name;
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_$name";

      final file = File(filePath);
      //final fileBytes = await file.readAsBytes();

      try {
        final supabase = Supabase.instance.client;
        await supabase.storage.from("manifestos").upload(fileName, file);
        final publicUrl = supabase.storage
            .from("manifestos")
            .getPublicUrl(fileName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("file uploadeed successfully"),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          pdfUploaded = true;
          uploadedPdfUrl = publicUrl;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // try {
      //   final supabase = Supabase.instance.client;

      //   final uploadResponse = await supabase.storage
      //       .from('manifestos')
      //       .uploadBinary(
      //         fileName,
      //         fileBytes,
      //         fileOptions: const FileOptions(upsert: true),
      //       );

      //   print('✅ Uploaded: $uploadResponse');
      //   // Show confirmation dialog or proceed
      // } catch (e) {
      //   print('❌ Upload error: $e');
      // }
    } else {
      print('⚠️ No file selected');
    }
  }

  void upload() async {
    await supabase
        .from('candidates')
        .update({'manifesto': uploadedPdfUrl})
        .eq('uid', widget.profile['id'])
        .eq('electionId', widget.elec['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Manifesto")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload PDF"),
              onPressed: pickAndUploadPDF,
            ),
            const SizedBox(height: 24),
            if (pdfUploaded)
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Submit"),
                onPressed: upload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
