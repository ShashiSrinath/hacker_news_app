import 'dart:convert';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'serializers.dart';
part 'hackernews.g.dart';

abstract class HackerNews implements Built<HackerNews , HackerNewsBuilder> {
  int get id ;

  @nullable
  bool get deleted ;
  String get type ; //  "job", "story", "comment", "poll", or "pollopt".
  @nullable
  String get by ;
  @nullable
  int get time ;
  @nullable
  String get text ;
  @nullable
  bool get dead ;
  @nullable
  int get parent ;
  @nullable
  int get poll ;
  BuiltList<int> get  kids ;
  @nullable
  String get url ;
  @nullable
  int get score ;
  @nullable
  String get title ;
  BuiltList<int> get parts ;
  @nullable
  int get decendants ;

  HackerNews._();

  factory HackerNews([updates(HackerNewsBuilder b)]) = _$HackerNews ;
  static Serializer<HackerNews> get serializer => _$hackerNewsSerializer ;

}

HackerNews parseHackerNews(String jsonStr) {
  final parsed =  jsonDecode(jsonStr);
  HackerNews hackerNews = standardSerializers.deserializeWith(HackerNews.serializer, parsed) ;
  return hackerNews ;
}