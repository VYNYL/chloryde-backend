import '../Core/archetype.dart';

class Question extends Archetype {

  List<String> Fields = [
    'id',
    'author',
    'title',
    'body'
  ];

  String Table = "questions";

}