import React from 'react';
import {Button} from "reactstrap";
import {Language} from "../types";

const LanguageTag:React.FC<{language: Language}> = ({language}) => {
    return (
        <Button
            key={language.lang}
            color="info"
            size="sm"
            style={{marginRight: '10px'}}
        >
            {language.lang}
            {' | '}
            {language.percentage}%
        </Button>
    );
};

export default LanguageTag;