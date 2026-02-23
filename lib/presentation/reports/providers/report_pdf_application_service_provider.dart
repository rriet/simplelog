import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/reports/application/report_pdf_application_service.dart';

/// Public API documentation.
final reportPdfApplicationServiceProvider =
    Provider<ReportPdfApplicationService>(
      (ref) => const ReportPdfApplicationService(),
    );
