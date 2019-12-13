import * as React from "react";
import {Spinner} from "reactstrap";

const FullWidthSpinner: React.FC = () =>
    <div style={{display: 'flex', minHeight: "70vh"}}>
        <Spinner style={{width: '6rem', height: '6rem', margin: '120px auto'}}/>
    </div>;

export default FullWidthSpinner;