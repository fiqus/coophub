import React from 'react';
import {ApiResponse, Repo, TotalLanguage} from "../types";
import {Doughnut} from 'react-chartjs-2';
import useFetch from 'fetch-suspense';
import 'chartjs-plugin-colorschemes';
import getLangColor from '../languageColors';

type urlProp = {url:string};

const LanguagesChart: React.FC<urlProp> = ({languages}) => {
    if (!languages.data) {
        return null;
    }
    const firstsLanguages = Object.keys(languages.data).sort(
        (lA, lB) => languages.data[lB].percentage - languages.data[lA].percentage
    ).slice(0, 7);
    let langs = firstsLanguages.map(function(key) {
         return key;
    });
    langs.push('other')

    let percentages = firstsLanguages.map(function(key) {
        const lang = languages.data[key];
        return lang.percentage;
    });
    percentages.push(Math.round((100.0 - percentages.reduce((a,b)=>a+b, 0)) * 100)/100)

    const data = {
        labels: langs,
        datasets: [{
            data: percentages,
            backgroundColor: langs.map(l => getLangColor(l))
        }],
    };

    const options = {
        legend: {
            position: 'right',
            labels: {
                padding: 15
            }
        },
        layout: {
            padding: {
                left: 0,
                right: 0,
                top: 0,
                bottom: 0
            }
        },
        responsive: true,
        rotation: 1 * Math.PI,
        circumference: 1 * Math.PI,
        tooltips: {
            callbacks: {
                label: function(tooltipItem, data) {
                    const dataset = data.datasets[tooltipItem.datasetIndex];
                    const currentValue = dataset.data[tooltipItem.index];     
                    const label = data.labels[tooltipItem.index]  
                    return `${label}: ${currentValue}%`;
                }
            }
        }
    };

    return <Doughnut data={data} options={options}/>;
};

export default LanguagesChart;