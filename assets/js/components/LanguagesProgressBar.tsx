import React from 'react';
import { Language } from "../types";
import getLangColor from '../languageColors';

const LanguagesProgressBar: React.FC<{ languages: Array<Language>, maxLanguages: number }> = ({ languages, maxLanguages }) => {
    let mainLanguages = languages.slice(0, maxLanguages);
    mainLanguages.push({ lang: "other", percentage: Math.round((100.0 - (mainLanguages.reduce((acc, lang) => acc + lang.percentage, 0))) * 100) / 100})
    mainLanguages = mainLanguages.filter(l=>l.percentage > 0);

    return <>
        <div className="lang-progress-bar">
            {mainLanguages.map((l, key) => {
                return <div key={key} style={{ width: `${l.percentage}%`, backgroundColor: getLangColor(l.lang) }}>
                </div>
            })}
        </div>
        <div className="lang-progress-bar-names">
            {mainLanguages.map((l, key) => {
                return <div key={key}>
                    <div className="lang-color-circle" style={{backgroundColor: getLangColor(l.lang) }}></div>
                    <span>{l.lang} - {l.percentage}%</span>
                </div>
            })}
        </div>
    </>;
};

export default LanguagesProgressBar;