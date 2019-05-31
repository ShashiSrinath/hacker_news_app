import 'package:built_collection/built_collection.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/serializer.dart';
import 'package:hacker_news_app/models/hackernews.dart';

part 'serializers.g.dart';

@SerializersFor(const [HackerNews,])
Serializers serializers = _$serializers;

Serializers standardSerializers = (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build() ;


