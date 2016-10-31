import '../Core/archetype.dart';

class Question extends Archetype {

  List<String> Fields = [
    'id',
    'author',
    'title',
    'body',
    'tags'
  ];

  String Table = "questions";

}