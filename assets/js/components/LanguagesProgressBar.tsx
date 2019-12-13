import React from 'react';
import {Language} from "../types";
import { Container } from 'reactstrap';
import { HorizontalBar } from 'react-chartjs-2';
import getLangColor from '../languageColors';

const LanguagesProgressBar:React.FC<{languages: Array<Language>, maxLanguages: number}> = ({languages, maxLanguages}) => {
    let mainLanguages = languages.slice(0, maxLanguages);
    const options = {
        scales: {
             xAxes: [{stacked: true, display: false}],
             yAxes: [{stacked: true, display: false}]
         },
         tooltips: {enabled: false},
         height: 10
     }
     mainLanguages.push({bytes: 0,lang: "other", percentage: 100.0 - (mainLanguages.reduce((acc, lang) => acc + lang.percentage, 0))})
     const data ={ 
       datasets: mainLanguages.map(i => {return {label: `${i.lang} (${Number(i.percentage).toFixed(2)}%)`, 
                                                 barThickness: 10,
                                                 backgroundColor: getLangColor(i.lang),
                                                 data: [i.percentage]}}),
       labels:['languages']
     } 

    return (
        <HorizontalBar height={20} data={data} options={options}></HorizontalBar>
    );
};

export default LanguagesProgressBar;