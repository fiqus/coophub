import React from 'react';
import { Language } from "../types";
import { Container, Tooltip, UncontrolledTooltip } from 'reactstrap';
import { HorizontalBar } from 'react-chartjs-2';
import getLangColor from '../languageColors';

const LanguagesProgressBar: React.FC<{ languages: Array<Language>, maxLanguages: number }> = ({ languages, maxLanguages }) => {
    let mainLanguages = languages.slice(0, maxLanguages);
    mainLanguages.push({ bytes: 0, lang: "other", percentage: Math.round((100.0 - (mainLanguages.reduce((acc, lang) => acc + lang.percentage, 0))) * 100) / 100})

    return <div className="lang-progress-bar">
        {mainLanguages.map((l, key) => {
            return <div key={key} style={{ width: `${l.percentage}%`, backgroundColor: getLangColor(l.lang) }} id={"tooltip" + key}>
                <UncontrolledTooltip placement="top" target={"tooltip" + key}>
                    {`${l.lang} - ${l.percentage}%`}
                </UncontrolledTooltip>
            </div>
        })}
    </div>;
};

export default LanguagesProgressBar;