import * as React from 'react';
import {BrowserRouter, Route, Switch} from 'react-router-dom';

import Header from './components/Header';
import HomePage from './pages';
import OrgPage from './pages/org';

export default class Root extends React.Component {
    public render(): JSX.Element {
        return (
            <>
                <BrowserRouter>
                    <Header/>
                    <Switch>
                        <Route exact path="/" component={HomePage}/>
                        <Route path="/orgs/:name" component={OrgPage} />
                    </Switch>
                </BrowserRouter>
            </>
        )
    }
}
