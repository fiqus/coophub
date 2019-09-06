import * as React from 'react';
import {Suspense} from 'react';
import {RouteComponentProps} from 'react-router-dom';
import {CardDeck, Container, Jumbotron} from "reactstrap";
import useFetch from 'fetch-suspense';

import 'bootstrap/dist/css/bootstrap.css';
import {ApiResponse, Repo} from "../types";
import RepoCard from "../components/RepoCard";
import FullWidthSpinner from "../components/FullWidthSpinner";

type ReposResponse = ApiResponse<[Repo]>
type RepoListProps = {url:string}

const RepoList: React.FC<RepoListProps> = ({url}) => {
    const response = useFetch(url) as ReposResponse;
    return <CardDeck>
        {response.data.map((repo, i)=><RepoCard repo={repo} key={i}/>)}
    </CardDeck>;
};

const HomePage: React.FC<RouteComponentProps> = () => {
    return <>
        <Jumbotron fluid>
            <Container fluid>
                <h1 className="display-3">CoopHub</h1>
            </Container>
        </Jumbotron>

        <Container>
            <h2>Popular Repos</h2>
            <Suspense fallback={<FullWidthSpinner/>}>
                <RepoList url={"/api/repos?limit=3&sort=popular"}/>
            </Suspense>

            <h2>Latest Repos</h2>
            <Suspense fallback={<FullWidthSpinner/>}>
                <RepoList url={"/api/repos?limit=3&sort=latest"}/>
            </Suspense>
        </Container>
    </>;
};
export default HomePage
