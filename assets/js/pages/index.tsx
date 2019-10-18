import * as React from 'react';
import {Suspense} from 'react';
import {RouteComponentProps} from 'react-router-dom';
import {CardDeck, Container} from "reactstrap";
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
        <Container className="pt-xl-5">
            <div class="title-box text-center">
                <h3 class="title-a">
                Popular Repos
                </h3>
                <p class="subtitle-a">
                Most popular repos from coops
                </p>
                <div class="line-mf"></div>
            </div>
            <Suspense fallback={<FullWidthSpinner/>}>
                <RepoList url={"/api/repos?limit=3&sort=popular"}/>
            </Suspense>
            <br />
            <br />
            <br />
            <div id="latest" class="title-box text-center">
                <h3 class="title-a">
                Latest Repos
                </h3>
                <p class="subtitle-a">
                What's cooking at cooperatives?
                </p>
                <div class="line-mf"></div>
            </div>
            <Suspense fallback={<FullWidthSpinner/>}>
                <RepoList url={"/api/repos?limit=3&sort=latest"}/>
            </Suspense>
        </Container>
    </>;
};
export default HomePage
