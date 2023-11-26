import 'pdf_spannable_widget_base.dart';
import 'package:pdf/widgets.dart' as pw;

/// This class is used for creating [PdfMeasureableWidgetBase] implementation.
class PdfSpannableWidget extends PdfSpannableWidgetBase {
  PdfSpannableWidget({required pw.Widget widget}) : _widget = widget;

  final pw.Widget _widget;

  @override
  pw.Widget get widget => _widget;
}
