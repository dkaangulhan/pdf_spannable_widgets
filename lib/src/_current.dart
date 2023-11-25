part of 'pdf_measurable_widget_repo.dart';

/// Helps creating pdf pages by keeping current
/// page size and current widget list which
/// are not placed yet.
class _Current {
  /// This list keeps widgets that don't exceed
  /// page limits yet. So that, if a page is not
  /// filled, new widgets can be inserted that page.
  List<PdfMeasurableWidgetBase> _currentWidgetList = [];
  List<PdfMeasurableWidgetBase> get currentWidgetList => _currentWidgetList;
  double get currentWidgetListSize {
    double total = 0.0;
    for (PdfMeasurableWidgetBase w in _currentWidgetList) {
      total += w.size!.y;
    }
    return total;
  }

  /// Methods
  void resetCurrentWidgetList() => _currentWidgetList = [];
  void addCurrentWidgetList({required PdfMeasurableWidgetBase value}) =>
      _currentWidgetList.add(value);
  List<pw.Widget> get getPwWidgets {
    return currentWidgetList.map((e) => e.widget).toList();
  }
}
