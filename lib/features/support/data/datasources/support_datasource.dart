import 'package:w51/features/support/domain/entities/support_report.dart';

abstract interface class SupportDatasource {
  Future<String> submit(SupportReport report);
}
