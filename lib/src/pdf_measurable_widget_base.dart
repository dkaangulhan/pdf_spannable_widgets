import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// This is base class for constructing pdf widgets
/// that behave according to page size.
///
/// This class is for being able to find laid
/// out widget's sizes.
///
/// [subList] is stuffed when [PdfWidgetRepo.add]'s [isSubWidget]
/// parameter is true. Read the method's documentation for more info.
abstract class PdfMeasurableWidgetBase {
  pw.Widget get widget;
  PdfPoint? get size {
    return widget.box?.size;
  }

  final List<PdfMeasurableWidgetBase> _subList = [];
  List<PdfMeasurableWidgetBase> get subList => _subList;

  /// if true, there are [PdfMeasurableWidget]s.
  bool get hasSubWidget => _subList.isNotEmpty;
  void addToSublist({required PdfMeasurableWidgetBase widget}) =>
      _subList.add(widget);

  @override
  String toString() {
    return 'size: $size';
  }
}
