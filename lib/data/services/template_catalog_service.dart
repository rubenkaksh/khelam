import '../../../domain/models/template_info.dart';
import '../../../domain/repositories/template_service.dart';

class TemplateCatalogService implements TemplateService {
  const TemplateCatalogService();

  @override
  Future<TemplateInfo> fetchTemplateInfo() async {
    return const TemplateInfo(
      name: 'Khelam Flutter Clean Architecture',
      description:
          'Starter project with strict separation of UI, data, and domain logic.',
      layers: <String>[
        'UI (Views + ViewModels)',
        'Data (Services + Repositories)',
        'Domain (Models + Use Cases)',
      ],
      featureWorkflow: <String>[
        'Define domain model',
        'Create service',
        'Create repository',
        'Add use case (if needed)',
        'Build view model',
        'Build view',
        'Wire dependencies',
        'Add tests',
      ],
    );
  }
}
