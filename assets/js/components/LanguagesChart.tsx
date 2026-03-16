import React from 'react';
import {ApiResponse, TotalLanguage} from "../types";
import {Doughnut} from 'react-chartjs-2';
import {Chart as ChartJS, ArcElement, Tooltip, Legend} from 'chart.js';
import getLangColor from '../languageColors';

ChartJS.register(ArcElement, Tooltip, Legend);

type LanguagesChartProp = {languages:ApiResponse<[TotalLanguage]>};

const LanguagesChart: React.FC<LanguagesChartProp> = ({languages}) => {
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
        maintainAspectRatio: false,
        plugins: {
            legend: {
                position: 'bottom' as const,
                labels: {
                    padding: 15
                }
            },
            tooltip: {
                callbacks: {
                    label: function(context) {
                        const label = context.label || '';
                        const value = context.parsed;
                        return `${label}: ${value}%`;
                    }
                }
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
    };

    return <Doughnut data={data} options={options} height={250} />;
};

export default LanguagesChart;
