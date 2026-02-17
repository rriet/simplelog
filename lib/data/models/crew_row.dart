import 'package:simplelog/data/database/app_database.dart';

class CrewRow {
  const CrewRow(this.crew);

  final CrewData crew;

  int get id => crew.id;
  String get name => crew.name;
  bool get isFavorite => crew.isFavorite;
  bool get isLocked => crew.isLocked;
}
