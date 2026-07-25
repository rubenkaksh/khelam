class TemplateInfo {
  const TemplateInfo({
    required this.name,
    required this.description,
    required this.layers,
    required this.featureWorkflow,
  });

  final String name;
  final String description;
  final List<String> layers;
  final List<String> featureWorkflow;
}
