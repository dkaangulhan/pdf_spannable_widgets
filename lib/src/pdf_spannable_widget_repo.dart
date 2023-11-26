import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_spannable_widgets/src/index.dart';

part '_current.dart';

/// This repo keeps laid out widgets using [PdfSpannableWidget].
///
/// [pageMargin] is pdf package's [EdgeInsets] implementation.
class PdfSpannableWidgetRepo {
  PdfSpannableWidgetRepo({
    required this.pdfPageFormat,
  });

  /// This map is used to keep [PdfSpannableWidget] intances
  /// in order to place these widgets into pdf document.
  final Map<String, PdfSpannableWidgetBase> _map = {};

  // pw.Document _pdfDocument;
  PdfPageFormat pdfPageFormat;

  /// height of a pdf page. This controls
  /// when to break widgets into incoming pages.
  double get pageSize => pdfPageFormat.availableHeight;

  final _Current _current = _Current();

  // pw.Document get pdfDocument => _pdfDocument;

  // set pdfDocument(pw.Document value) {
  //   _pdfDocument = value;
  // }

  /// This adds widgets in [PdfSpannableWidget] with [key].
  ///
  /// if [isSubWidget] is true then it is added to [key]'s
  /// value's sub widget list.
  PdfSpannableWidgetBase add({
    required String key,
    required PdfSpannableWidgetBase pdfSpannableWidgetBase,
    bool isSubWidget = false,
  }) {
    if (isSubWidget) {
      final isKeyAvailable = _map[key] != null;
      assert(isKeyAvailable, true);

      _map[key]!.addToSublist(widget: pdfSpannableWidgetBase);
      return pdfSpannableWidgetBase;
    }

    _map[key] = pdfSpannableWidgetBase;
    return pdfSpannableWidgetBase;
  }

  /// List of values of keys;
  List<PdfSpannableWidgetBase> get _spannableWidgetList =>
      _map.keys.map((e) => _map[e]!).toList();

  /// This adds vertical seperation into map structure.
  PdfSpannableWidgetBase createVerticalSeperator({required double height}) {
    return add(
      key: 'vertical_seperator_${Random().nextInt(100000)}',
      pdfSpannableWidgetBase: PdfSpannableWidget(
        widget: pw.SizedBox(height: height),
      ),
    );
  }

  /// This method creates pdf whose sole widgets don't
  /// overflow to other pages.
  Future<Uint8List> createPdf() async {
    final pdf = pw.Document();

    _widgetLoop(pdfDocument: pdf, list: _spannableWidgetList);

    /// This closes page if widgets added to [Current.currentWidgetList]
    /// but not placed in any page during [widgetLoop].
    if (_current.currentWidgetList.isNotEmpty) {
      _closeCurrentPage(pdfDocument: pdf);
    }

    return await pdf.save();
  }

  /// This places widgets on pages.
  void _widgetLoop(
      {required pw.Document pdfDocument,
      required List<PdfSpannableWidgetBase> list}) {
    /* pseudo
      start loop
       if(widget.size > pageSize)
         if(widget.hasSubWidget)
           try place subWidgets in current page.
         else
         throw error
       else if(_Current.currentWidgetListSize + widget.size > pageSize)
         if(widget.hasSubWidget)
           try place subWidgets in current page.
         else
           closeCurrentPage()
           _Current.addCurrentWidgetList(widget)
       else if(widget is not last element of map)
         _Current.addCurrentWidgetList(widget)
       else
         closeCurrentPage()
      end; */

    for (int i = 0; i < list.length; i++) {
      final widget = list[i];
      final widgetSize = widget.size!.y;

      if (widgetSize > pageSize) {
        if (widget.hasSubWidget) {
          _widgetLoop(
            pdfDocument: pdfDocument,
            list: widget.subList,
          );
        } else {
          throw (
            'Widget is bigger than pageSize and it doesn\'t have any subWidget.',
          );
        }
      } else if (_current.currentWidgetListSize + widgetSize > pageSize) {
        if (widget.hasSubWidget) {
          _widgetLoop(
            pdfDocument: pdfDocument,
            list: widget.subList,
          );
        } else {
          _closeCurrentPage(pdfDocument: pdfDocument);
          _current.addCurrentWidgetList(value: widget);
        }
      } else if (widget != list.last) {
        _current.addCurrentWidgetList(value: widget);
      } else {
        _current.addCurrentWidgetList(value: widget);
        _closeCurrentPage(pdfDocument: pdfDocument);
      }
    }
  }

  /// closes current page with widget in [_Current.currentWidgetList].
  void _closeCurrentPage({
    required pw.Document pdfDocument,
  }) {
    pdfDocument.addPage(
      pw.MultiPage(
        pageFormat: pdfPageFormat,
        build: (context) {
          return _current.getPwWidgets;
        },
      ),
    );
    _current.resetCurrentWidgetList();
  }
}
