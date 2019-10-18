import * as React from 'react';
import {BrowserRouter, Route, Switch} from 'react-router-dom';

import Header from './components/Header';
import Footer from './components/Footer';
import HomePage from './pages';
import OrgPage from './pages/org';
import {Suspense} from "react";
import FullWidthSpinner from "./components/FullWidthSpinner";

export default class Root extends React.Component {
    public render(): JSX.Element {
        return (
            <>
                <BrowserRouter>
                    <Header/>
                    <Suspense fallback={<FullWidthSpinner/>}>
                        <Switch>
                            <Route exact path="/" component={HomePage}/>
                            <Route path="/orgs/:name" component={OrgPage} />
                        </Switch>
                    </Suspense>
                    <Footer/>
                </BrowserRouter>
            </>
        )
    }
}
