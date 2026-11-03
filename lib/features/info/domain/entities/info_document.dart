class InfoSection {
  const InfoSection({required this.heading, required this.body});

  final String heading;
  final String body;
}

class InfoDocument {
  const InfoDocument({
    required this.slug,
    required this.title,
    required this.updatedLabel,
    required this.sections,
  });

  final String slug;
  final String title;
  final String updatedLabel;
  final List<InfoSection> sections;
}
