class HelperMethods{


  static String splitDisplayName(String name) {
    if (name != null) {
      final split = name.split(',');
      final Map<int, String> values = {
        for (int i = 0; i < split.length; i++) i: split[i]
      };

      return "${values[0]},،${values[1]}";
    } else {
      return "";
    }
  }
}