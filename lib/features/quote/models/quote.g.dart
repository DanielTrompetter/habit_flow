// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quote _$QuoteFromJson(Map<String, dynamic> json) => Quote(
  id: (json['id'] as num).toInt(),
  quote: json['quote'] as String,
  author: json['author'] as String,
);

Map<String, dynamic> _$QuoteToJson(Quote instance) => <String, dynamic>{
  'id': instance.id,
  'quote': instance.quote,
  'author': instance.author,
};

