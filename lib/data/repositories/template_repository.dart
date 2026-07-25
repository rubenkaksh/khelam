import '../../domain/models/template_info.dart';
import '../../domain/repositories/template_service.dart';

class TemplateRepository {
  TemplateRepository({required TemplateService service}) : _service = service;

  final TemplateService _service;

  Future<TemplateInfo> getTemplateInfo() {
    return _service.fetchTemplateInfo();
  }
}
