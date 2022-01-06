/*
class CountryNamesTranslator{
  static Future<List<String>> translate(List<String> names) async {
    final translator = GoogleTranslator();

    for(int i = 0; i < names.length; i++){
      names[i] = (await translator.translate(names[i], from: 'en', to: 'hu')).text;
    }
    return names;
  }
}


 */
