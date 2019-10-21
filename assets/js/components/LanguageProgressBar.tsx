import React from 'react';
import {Language} from "../types";
import { Container } from 'reactstrap';

const LanguageProgressBar:React.FC<{language: Language}> = ({language}) => {
    /** @type {{search: React.CSSProperties}} */
    const styles = {
        width: `${language.percentage}%`
    };
    return (
        <Container className="col-2">
            <span> {language.lang} </span> 
            <span class="pull-right"> {language.percentage}%</span>
            <span class="progress">
                <span class="progress-bar" role="progressbar"  style= {styles} aria-valuenow={language.percentage} aria-valuemin="0" aria-valuemax="100"></span>
            </span>
        </Container>
    );
};

export default LanguageProgressBar;