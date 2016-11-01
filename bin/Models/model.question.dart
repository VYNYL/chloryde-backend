import '../Core/archetype.dart';

class Question extends Archetype {

  List<String> Fields = [
    'id',
    'author',
    'title',
    'body',
    'tags'
  ];

  Map Schema = {
    "\$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
      "title": {
        "type": "string",
        "minLength": 10,
        "maxLength": 35
      },
      "body": {
        "type": "string",
        "minLength": 50,
        "maxLength": 65530
      },
      "tags": {
        "type": "array",
        "minItems": 1,
        "uniqueItems": true,
        "items": {
          "type": "object",
          "properties": {
            "name": {
              "type": "string"
            },
            "type": {
              "type": "string"
            }
          },
          "required": [
            "name",
            "type"
          ]
        }
      }
    },
    "required": [
      "title",
      "body",
      "tags"
    ]
  };

  String Table = "questions";

}