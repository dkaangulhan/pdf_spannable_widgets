import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:pdf_spannable_widgets/pdf_spannable_widgets.dart';

Future<Uint8List> generatePdf() async {
  PdfSpannableWidgetRepo pdfRepo = PdfSpannableWidgetRepo(
    pageMargin: pw.EdgeInsets.zero,
    pdfPageFormat: PdfPageFormat.a4,
  );

  /// Here pdf document is created for calculating widgets' sizes.
  final samplePdf = pw.Document();

  /// This creates a pdf document, where [height] is 100.0
  /// so that widgets can be built without throwing error
  /// of "This widget created more than 20 pages.
  /// This may be an issue in the widget or the document".
  ///
  /// Note that 100.0 here is a number that your all widgets will
  /// probably fit in. If you think the whole widget tree would
  /// exceed this threshold, you should increase it.
  samplePdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(height: 100.0),
      build: (context) {
        return <pw.Widget>[
          pdfRepo
              .add(
                key: 'unique-widget-key',
                pdfSpannableWidgetBase: PdfSpannableWidget(
                    widget: pw.Placeholder() // your widget will come here.,
                    ),
              )
              .widget,

          /// ... more widgets
        ];
      },
    ),
  );

  /// Will create the pdf.
  return await pdfRepo.createPdf();
}
