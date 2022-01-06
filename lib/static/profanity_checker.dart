import 'package:profanity_filter/profanity_filter.dart';

class ProfanityChecker{
  static bool alert(String text){
    ProfanityFilter profanityFilter = ProfanityFilter();
    return profanityFilter.hasProfanity(text);
  }
}
