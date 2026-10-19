import 'package:w51/features/home/domain/entities/home_entities.dart';

abstract interface class HomeRepository {
  Future<HomeData> load();
}
