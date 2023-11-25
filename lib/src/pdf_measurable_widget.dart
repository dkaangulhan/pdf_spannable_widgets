import './pdf_measurable_widget_base.dart';
import 'package:pdf/widgets.dart' as pw;

/// This class is used for creating [PdfMeasureableWidgetBase] implementation.
class PdfMeasurableWidget extends PdfMeasurableWidgetBase {
  PdfMeasurableWidget({required pw.Widget widget}) : _widget = widget;

  final pw.Widget _widget;

  @override
  pw.Widget get widget => _widget;
}
