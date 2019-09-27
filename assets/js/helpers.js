const Helpers = {
  get_languages(languages) {
    const langs = Object.keys(languages).map(lang => {
        return {
            lang,
            bytes: languages[lang]
        };
    });
    langs.sort((a, b) => (a.bytes <= b.bytes) ? 1 : -1);
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