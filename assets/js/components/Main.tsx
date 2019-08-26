import * as React from 'react';
import {Container} from "reactstrap";

const Main: React.FC = ({ children }) => (
    <Container>
        {children}
    </Container>
);

export default Main
