import '../../domain/models/template_info.dart';

abstract interface class TemplateService {
  Future<TemplateInfo> fetchTemplateInfo();
}
