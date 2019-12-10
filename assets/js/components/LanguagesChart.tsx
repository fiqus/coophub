import React from 'react';
import {ApiResponse, Repo, TotalLanguage} from "../types";
import {Doughnut} from 'react-chartjs-2';
import useFetch from 'fetch-suspense';
import 'chartjs-plugin-colorschemes';

type LanguagesResponse = ApiResponse<[TotalLanguage]>;
type urlProp = {url:string};

const LanguagesChart: React.FC<urlProp> = ({url}) => {
    const response = useFetch(url) as LanguagesResponse;
    const firstsLanguages = Object.keys(response.data).sort(
        (lA, lB) => response.data[lB].percentage - response.data[lA].percentage
    ).slice(0, 16);
    const langs = firstsLanguages.map(function(key) {
         return key;
    });
    const percentages = firstsLanguages.map(function(key) {
        const lang = response.data[key];
        return lang.percentage;
    });

    const data = {
        labels: langs,
        datasets: [{
            data: percentages
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
        plugins: {
            colorschemes: {
                scheme: 'tableau.Tableau20'
            }
        },
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