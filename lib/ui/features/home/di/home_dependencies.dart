import 'package:get_it/get_it.dart';

import '../../../../data/repositories/template_repository.dart';
import '../../../../data/services/template_catalog_service.dart';
import '../../../../domain/repositories/template_service.dart';
import '../bloc/home_cubit.dart';

abstract final class HomeDependencies {
  static void register(GetIt locator) {
    locator.registerLazySingleton<TemplateService>(
      () => const TemplateCatalogService(),
    );
    locator.registerLazySingleton<TemplateRepository>(
      () => TemplateRepository(service: locator<TemplateService>()),
    );
    locator.registerLazySingleton<HomeCubit>(
      () => HomeCubit(repository: locator<TemplateRepository>()),
    );
  }
}
