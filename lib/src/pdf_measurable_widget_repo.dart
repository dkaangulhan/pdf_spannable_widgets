import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_spannable_widgets/src/index.dart';

part '_current.dart';

/// This repo keeps laid out widgets using [PdfMeasurableWidget].
///
/// [pdfDocuemnt] is the pdf that will produce the pdf file.
class PdfMeasurableWidgetRepo {
  PdfMeasurableWidgetRepo({
    required EdgeInsets pageMargin,
    required this.pdfPageFormat,
    this.pageSize = 720.0,
  }) : _pageMargin = pw.EdgeInsets.only(
          left: pageMargin.left,
          top: pageMargin.top,
          right: pageMargin.right,
          bottom: pageMargin.bottom,
        );

  /// This map is used to keep [PdfMeasurableWidget] intances
  /// in order to place these widgets into pdf document.
  final Map<String, PdfMeasurableWidgetBase> _map = {};

  // pw.Document _pdfDocument;
  final pw.EdgeInsets? _pageMargin;
  PdfPageFormat pdfPageFormat;

  /// height of a pdf page. This controls
  /// when to break widgets into incoming pages.
  double pageSize;

  final _Current _current = _Current();

  // pw.Document get pdfDocument => _pdfDocument;

  // set pdfDocument(pw.Document value) {
  //   _pdfDocument = value;
  // }

  /// This adds widgets in [PdfMeasurableWidget] with [key].
  ///
  /// if [isSubWidget] is true then it is added to [key]'s
  /// value's sub widget list.
  PdfMeasurableWidgetBase add({
    required String key,
    required PdfMeasurableWidgetBase pdfMeasurableWidgetBase,
    bool isSubWidget = false,
  }) {
    if (isSubWidget) {
      final isKeyAvailable = _map[key] != null;
      assert(isKeyAvailable, true);

      _map[key]!.addToSublist(widget: pdfMeasurableWidgetBase);
      return pdfMeasurableWidgetBase;
    }

    _map[key] = pdfMeasurableWidgetBase;
    return pdfMeasurableWidgetBase;
  }

  /// List of values of keys;
  List<PdfMeasurableWidgetBase> get _measurableWidgetList =>
      _map.keys.map((e) => _map[e]!).toList();

  /// This adds vertical seperation into map structure.
  PdfMeasurableWidgetBase createVerticalSeperator({required double height}) {
    return add(
      key: 'vertical_seperator_${Random().nextInt(100000)}',
      pdfMeasurableWidgetBase: PdfMeasurableWidget(
        widget: pw.SizedBox(height: height),
      ),
    );
  }

  /// This method creates pdf whose sole widgets don't
  /// overflow to other pages.
  Future<Uint8List> createPdf() async {
    final pdf = pw.Document();

    _widgetLoop(pdfDocument: pdf, list: _measurableWidgetList);

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
      required List<PdfMeasurableWidgetBase> list}) {
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
        margin: _pageMargin,
        build: (context) {
          return _current.getPwWidgets;
        },
      ),
    );
    _current.resetCurrentWidgetList();
  }
}
