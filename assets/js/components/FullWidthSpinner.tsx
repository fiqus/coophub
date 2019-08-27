import * as React from "react";
import {Spinner} from "reactstrap";

const FullWidthSpinner: React.FC = () =>
    <div style={{display: 'flex'}}>
        <Spinner style={{width: '6rem', height: '6rem', margin: '20px auto'}}/>
    </div>;

export default FullWidthSpinner;