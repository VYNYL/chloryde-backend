import 'Core/router.dart';
import 'Controllers/control.question.dart';
import 'Models/model.question.dart';

class Routes extends Router {

  Routes() {

    Sync("questions", CtrlQuestion.SyncQuestion, new Question());

    Put("questions", CtrlQuestion.PutQuestion);

    Get("questions", CtrlQuestion.GetQuestion);


  }

}

