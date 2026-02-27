import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simplelog/features/reports/application/report_pdf_application_service.dart';

/// Provides the application service that builds and saves report PDFs.
final reportPdfApplicationServiceProvider =
    Provider<ReportPdfApplicationService>(
      (ref) => const ReportPdfApplicationService(),
    );
