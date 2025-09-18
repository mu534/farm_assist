class User {
  final String id;
  final String name;
  final String language;

  User({required this.id, required this.name, this.language = 'en'});
}
