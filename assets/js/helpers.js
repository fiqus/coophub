const Helpers = {
  list_languages(langs, num = 2, separator = "+") {
    return langs.slice(0, num)
      .map(l => l.lang)
      .join(` ${separator} `);
  }
};

export default Helpers;