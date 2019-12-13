import * as React from 'react';
import {BrowserRouter, Route, Switch} from 'react-router-dom';

import Header from './components/Header';
import Footer from './components/Footer';
import HomePage from './pages';
import OrgPage from './pages/org';
import TopicsPage from './pages/topics';
import SearchResultsPage from './pages/searchResults';
import LanguageReposPage from './pages/languageRepos';
import {Suspense} from "react";
import FullWidthSpinner from "./components/FullWidthSpinner";
import { Container } from 'reactstrap';

export default class Root extends React.Component {
    public render(): JSX.Element {
        return (
            <>
                <BrowserRouter>
                    <Header />
                    
                    <Suspense fallback={<FullWidthSpinner />}>
                        <Switch>
                            <Route exact path="/" component={HomePage}/>
                            <Route path="/orgs/:name" component={OrgPage} />
                            <Route path="/topics/:topic" component={TopicsPage} />
                            <Route path="/search" component={SearchResultsPage} />
                            <Route path="/languages/:lang" component={LanguageReposPage} />
                        </Switch>
                    </Suspense>
                    <Footer/>
                </BrowserRouter>
            </>
        )
    }
}
