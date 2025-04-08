import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

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
  bool isUploading = false;
  String? uploadedPdfUrl;
  String? localPdfPath;
  int currentPage = 0;
  int? totalPages;

  final client = Supabase.instance.client;

  // Vibrant colors for the UI
  final List<Color> gradientColors = [
    const Color(0xFF6A11CB),
    const Color(0xFF2575FC),
  ];

  final Color accentColor = const Color(0xFFFFA500);
  final Color successColor = const Color(0xFF00C853);
  final Color errorColor = const Color(0xFFFF3D71);
  final Color warningColor = const Color(0xFFFFAB40);
  final Color cardColor = const Color(0xFFF0F8FF);

  void _showColoredSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              backgroundColor == successColor
                  ? Icons.check_circle
                  : backgroundColor == errorColor
                  ? Icons.error
                  : Icons.info,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
        elevation: 6,
      ),
    );
  }

  Future<void> pickAndUploadPDF() async {
    setState(() {
      isUploading = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) {
        _showColoredSnackBar(
          "No file selected! Please choose a PDF file.",
          warningColor,
        );
        setState(() {
          isUploading = false;
        });
        return;
      }

      final filePath = result.files.single.path!;
      final name = result.files.single.name;

      if (!name.toLowerCase().endsWith('.pdf')) {
        _showColoredSnackBar("Please select a PDF file only!", errorColor);
        setState(() {
          isUploading = false;
        });
        return;
      }

      final fileName = "${DateTime.now().millisecondsSinceEpoch}_$name";
      final file = File(filePath);

      try {
        final supabase = Supabase.instance.client;

        // Upload file
        await supabase.storage.from("manifestos").upload(fileName, file);

        // Get public URL
        final publicUrl = supabase.storage
            .from("manifestos")
            .getPublicUrl(fileName);

        // Store local path for preview
        setState(() {
          localPdfPath = filePath;
          pdfUploaded = true;
          uploadedPdfUrl = publicUrl;
          isUploading = false;
        });

        _showColoredSnackBar(
          "🎉 Your manifesto was uploaded successfully!",
          successColor,
        );
      } catch (e) {
        _showColoredSnackBar("Upload failed: ${e.toString()}", errorColor);
        setState(() {
          isUploading = false;
        });
      }
    } catch (e) {
      _showColoredSnackBar("File selection error: ${e.toString()}", errorColor);
      setState(() {
        isUploading = false;
      });
    }
  }

  void upload() async {
    setState(() {
      isUploading = true;
    });

    try {
      await Supabase.instance.client
          .from('candidates')
          .update({'manifesto': uploadedPdfUrl})
          .eq('uid', widget.profile['id'])
          .eq('electionId', widget.elec['id']);

      _showColoredSnackBar(
        "🚀 Manifesto submitted successfully!",
        successColor,
      );

      // Navigate back after successful submission
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context, true);
      });
    } catch (e) {
      _showColoredSnackBar(
        "Error saving manifesto: ${e.toString()}",
        errorColor,
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Upload Manifesto",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientColors[1].withOpacity(0.1),
              Colors.white,
              Colors.white,
              gradientColors[0].withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colorful Header Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [gradientColors[0], gradientColors[1]],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.upload_file,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Your Manifesto",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Let voters know your vision!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Upload a PDF document containing your election manifesto. This document will be accessible to voters during the election.",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(
                            isUploading
                                ? Icons.hourglass_empty
                                : Icons.file_upload,
                            color: gradientColors[0],
                          ),
                          label: Text(
                            isUploading ? "Uploading..." : "Select PDF File",
                            style: TextStyle(
                              color: gradientColors[0],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: isUploading ? null : pickAndUploadPDF,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Upload Progress Indicator
              if (isUploading)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(accentColor),
                          strokeWidth: 6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Processing your manifesto...",
                        style: TextStyle(
                          color: gradientColors[0],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Please wait while we upload your file",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),

              // PDF Preview
              if (localPdfPath != null && !isUploading)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.visibility, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  "Document Preview",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            if (totalPages != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Page ${currentPage + 1}/$totalPages",
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            child: PDFView(
                              filePath: localPdfPath!,
                              enableSwipe: true,
                              swipeHorizontal: true,
                              autoSpacing: false,
                              pageFling: true,
                              onPageChanged: (page, total) {
                                setState(() {
                                  currentPage = page!;
                                  totalPages = total;
                                });
                              },
                              onRender: (pages) {
                                setState(() {
                                  totalPages = pages;
                                });
                              },
                              onError: (error) {
                                _showColoredSnackBar(
                                  "Error loading PDF: $error",
                                  errorColor,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Submit Button
              if (pdfUploaded && !isUploading)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [successColor, const Color(0xFF69F0AE)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: successColor.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                        label: const Text(
                          "Submit Manifesto",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        onPressed: upload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}






// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';

// class ManifestoUploadPage extends StatefulWidget {
//   final Map<String, dynamic> profile;
//   final Map<String, dynamic> elec;

//   const ManifestoUploadPage({
//     super.key,
//     required this.profile,
//     required this.elec,
//   });

//   @override
//   State<ManifestoUploadPage> createState() => _ManifestoUploadPageState();
// }

// class _ManifestoUploadPageState extends State<ManifestoUploadPage> {
//   bool pdfUploaded = false;
//   bool isUploading = false;
//   String? uploadedPdfUrl;
//   String? localPdfPath;
//   int currentPage = 0;
//   int? totalPages;

//   final client = Supabase.instance.client;

//   void _showColoredSnackBar(String message, Color backgroundColor) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: backgroundColor,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.all(12),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   Future<void> pickAndUploadPDF() async {
//     setState(() {
//       isUploading = true;
//     });

//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf'],
//       );

//       if (result == null || result.files.single.path == null) {
//         _showColoredSnackBar("No file selected", Colors.amber.shade700);
//         setState(() {
//           isUploading = false;
//         });
//         return;
//       }

//       final filePath = result.files.single.path!;
//       final name = result.files.single.name;

//       if (!name.toLowerCase().endsWith('.pdf')) {
//         _showColoredSnackBar("Please select a PDF file", Colors.red.shade700);
//         setState(() {
//           isUploading = false;
//         });
//         return;
//       }

//       final fileName = "${DateTime.now().millisecondsSinceEpoch}_$name";
//       final file = File(filePath);

//       try {
//         final supabase = Supabase.instance.client;

//         // Upload file
//         await supabase.storage.from("manifestos").upload(fileName, file);

//         // Get public URL
//         final publicUrl = supabase.storage
//             .from("manifestos")
//             .getPublicUrl(fileName);

//         // Store local path for preview
//         setState(() {
//           localPdfPath = filePath;
//           pdfUploaded = true;
//           uploadedPdfUrl = publicUrl;
//           isUploading = false;
//         });

//         _showColoredSnackBar(
//           "File uploaded successfully",
//           Colors.green.shade600,
//         );
//       } catch (e) {
//         _showColoredSnackBar(
//           "Upload error: ${e.toString()}",
//           Colors.red.shade700,
//         );
//         setState(() {
//           isUploading = false;
//         });
//       }
//     } catch (e) {
//       _showColoredSnackBar(
//         "File selection error: ${e.toString()}",
//         Colors.red.shade700,
//       );
//       setState(() {
//         isUploading = false;
//       });
//     }
//   }

//   void upload() async {
//     setState(() {
//       isUploading = true;
//     });

//     try {
//       await Supabase.instance.client
//           .from('candidates')
//           .update({'manifesto': uploadedPdfUrl})
//           .eq('uid', widget.profile['id'])
//           .eq('electionId', widget.elec['id']);

//       _showColoredSnackBar(
//         "Manifesto saved successfully",
//         Colors.green.shade600,
//       );

//       // Navigate back after successful submission
//       Future.delayed(const Duration(seconds: 1), () {
//         Navigator.pop(context, true);
//       });
//     } catch (e) {
//       _showColoredSnackBar(
//         "Error saving manifesto: ${e.toString()}",
//         Colors.red.shade700,
//       );
//     } finally {
//       setState(() {
//         isUploading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Upload Manifesto"),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               theme.primaryColor.withOpacity(0.05),
//               theme.scaffoldBackgroundColor,
//             ],
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Upload Your Manifesto",
//                         style: theme.textTheme.headlineSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         "Please select a PDF file containing your election manifesto. This document will be accessible to voters.",
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           color: Colors.grey.shade700,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.upload_file),
//                           label: Text(
//                             isUploading ? "Uploading..." : "Select PDF File",
//                           ),
//                           onPressed: isUploading ? null : pickAndUploadPDF,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               if (isUploading)
//                 const Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(24.0),
//                     child: Column(
//                       children: [
//                         CircularProgressIndicator(),
//                         SizedBox(height: 16),
//                         Text("Processing your file..."),
//                       ],
//                     ),
//                   ),
//                 ),
//               if (localPdfPath != null && !isUploading)
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Preview",
//                             style: theme.textTheme.titleLarge?.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           if (totalPages != null)
//                             Text(
//                               "Page ${currentPage + 1} of $totalPages",
//                               style: theme.textTheme.bodyMedium,
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.2),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: PDFView(
//                               filePath: localPdfPath!,
//                               enableSwipe: true,
//                               swipeHorizontal: true,
//                               autoSpacing: false,
//                               pageFling: true,
//                               onPageChanged: (page, total) {
//                                 setState(() {
//                                   currentPage = page!;
//                                   totalPages = total;
//                                 });
//                               },
//                               onViewCreated: (controller) {
//                                 // PDF view created
//                               },
//                               onRender: (pages) {
//                                 setState(() {
//                                   totalPages = pages;
//                                 });
//                               },
//                               onError: (error) {
//                                 _showColoredSnackBar(
//                                   "Error loading PDF: $error",
//                                   Colors.red.shade700,
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               const SizedBox(height: 16),
//               if (pdfUploaded && !isUploading)
//                 Center(
//                   child: SizedBox(
//                     width: MediaQuery.of(context).size.width * 0.8,
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.check_circle_outline),
//                       label: const Text("Submit Manifesto"),
//                       onPressed: upload,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// // import 'dart:io';
// // import 'dart:typed_data';
// // import 'package:flutter/material.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'package:univote/pages/userelctiondetails.dart';

// // class ManifestoUploadPage extends StatefulWidget {
// //   final Map<String, dynamic> profile;
// //   final Map<String, dynamic> elec;

// //   const ManifestoUploadPage({
// //     super.key,
// //     required this.profile,
// //     required this.elec,
// //   });

// //   @override
// //   State<ManifestoUploadPage> createState() => _ManifestoUploadPageState();
// // }

// // class _ManifestoUploadPageState extends State<ManifestoUploadPage> {
// //   bool pdfUploaded = false;
// //   String? uploadedPdfUrl;

// //   final client = Supabase.instance.client;

// //   Future<void> pickAndUploadPDF() async {
// //     final result = await FilePicker.platform.pickFiles();

// //     if (result != null && result.files.single.path != null) {
// //       final filePath = result.files.single.path!;
// //       final name = result.files.single.name;
// //       final fileName = "${DateTime.now().millisecondsSinceEpoch}_$name";

// //       final file = File(filePath);
// //       //final fileBytes = await file.readAsBytes();

// //       try {
// //         final supabase = Supabase.instance.client;
// //         await supabase.storage.from("manifestos").upload(fileName, file);
// //         final publicUrl = supabase.storage
// //             .from("manifestos")
// //             .getPublicUrl(fileName);
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text("file uploadeed successfully"),
// //             behavior: SnackBarBehavior.floating,
// //           ),
// //         );
// //         setState(() {
// //           pdfUploaded = true;
// //           uploadedPdfUrl = publicUrl;
// //         });
// //       } catch (e) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text(e.toString()),
// //             behavior: SnackBarBehavior.floating,
// //           ),
// //         );
// //       }

      
// //     } else {
// //       print('⚠️ No file selected');
// //     }
// //   }

// //   void upload() async {
// //     await supabase
// //         .from('candidates')
// //         .update({'manifesto': uploadedPdfUrl})
// //         .eq('uid', widget.profile['id'])
// //         .eq('electionId', widget.elec['id']);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Upload Manifesto")),
// //       body: Padding(
// //         padding: const EdgeInsets.all(24),
// //         child: Column(
// //           children: [
// //             ElevatedButton.icon(
// //               icon: const Icon(Icons.upload_file),
// //               label: const Text("Upload PDF"),
// //               onPressed: pickAndUploadPDF,
// //             ),
// //             const SizedBox(height: 24),
// //             if (pdfUploaded)
// //               ElevatedButton.icon(
// //                 icon: const Icon(Icons.check_circle_outline),
// //                 label: const Text("Submit"),
// //                 onPressed: upload,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.green,
// //                   foregroundColor: Colors.white,
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }


// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';


// class ManifestoUploadPage extends StatefulWidget {
//   final Map<String, dynamic> profile;
//   final Map<String, dynamic> elec;

//   const ManifestoUploadPage({
//     super.key,
//     required this.profile,
//     required this.elec,
//   });

//   @override
//   State<ManifestoUploadPage> createState() => _ManifestoUploadPageState();
// }

// class _ManifestoUploadPageState extends State<ManifestoUploadPage> {
//   bool pdfUploaded = false;
//   String? uploadedPdfUrl;
//   String? localPdfPath;

//   final client = Supabase.instance.client;

//   Future<void> pickAndUploadPDF() async {
//     final result = await FilePicker.platform.pickFiles();

//     if (result != null && result.files.single.path != null) {
//       final filePath = result.files.single.path!;
//       final name = result.files.single.name;
//       final fileName = "${DateTime.now().millisecondsSinceEpoch}_$name";

//       final file = File(filePath);

//       try {
//         final supabase = Supabase.instance.client;

//         // Upload file
//         await supabase.storage.from("manifestos").upload(fileName, file);

//         // Get public URL
//         final publicUrl =
//             supabase.storage.from("manifestos").getPublicUrl(fileName);

//         // Store local path for preview
//         setState(() {
//           localPdfPath = filePath;
//           pdfUploaded = true;
//           uploadedPdfUrl = publicUrl;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("File uploaded successfully"),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(e.toString()),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } else {
//       print('⚠️ No file selected');
//     }
//   }

//   void upload() async {
//     try {
//       await Supabase.instance.client
//           .from('candidates')
//           .update({'manifesto': uploadedPdfUrl})
//           .eq('uid', widget.profile['id'])
//           .eq('electionId', widget.elec['id']);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Manifesto URL saved successfully."),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error saving URL: $e"),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Upload Manifesto")),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ElevatedButton.icon(
//               icon: const Icon(Icons.upload_file),
//               label: const Text("Upload PDF"),
//               onPressed: pickAndUploadPDF,
//             ),
//             const SizedBox(height: 24),
//             if (localPdfPath != null)
//               Expanded(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: PDFView(
//                     filePath: localPdfPath!,
//                     enableSwipe: true,
//                     swipeHorizontal: true,
//                     autoSpacing: false,
//                     pageFling: true,
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 16),
//             if (pdfUploaded)
//               Center(
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.check_circle_outline),
//                   label: const Text("Submit"),
//                   onPressed: upload,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
