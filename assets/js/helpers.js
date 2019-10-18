const Helpers = {
  get_languages(langs) {
    
    if (langs.length > 1) {
        return langs[0].lang + ", " + langs[1].lang;
    } else if (langs.length === 1) {
        return langs[0].lang;
    } else {
        return "";
    }
  }
};

export default Helpers;