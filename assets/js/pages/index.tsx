import * as React from 'react';
import {Suspense} from 'react';
import {RouteComponentProps} from 'react-router-dom';
import {CardDeck, Container} from "reactstrap";
import useFetch from 'fetch-suspense';

import {ApiResponse, Repo} from "../types";
import RepoCard from "../components/RepoCard";
import FullWidthSpinner from "../components/FullWidthSpinner";
import _ from "lodash";

type ReposResponse = ApiResponse<[Repo]>
type RepoListProps = {url:string}

const RepoList: React.FC<RepoListProps> = ({url}) => {
    const response = useFetch(url) as ReposResponse;
    return <>
        {_.chunk(response.data, 3).map((row, i)=>
            <CardDeck key={i}>
                {row.map((repo, j)=><RepoCard repo={repo} key={i*10+j}/>)}
            </CardDeck>)}
    </>;
};

const HomePage: React.FC<RouteComponentProps> = () => {
    return <>
        <Container className="pt-xl-5">
            <form action="/api/search" method="get" className="text-center">
                <input name="q" placeholder="Search repos.."/>
            </form>
            <div className="title-box text-center">
                <h3 className="title-a">
                Popular Repos
                </h3>
                <p className="subtitle-a">
                Most popular repos from coops
                </p>
                <div className="line-mf"/>
            </div>
            <Suspense fallback={<FullWidthSpinner/>}>
                <RepoList url={"/api/repos?limit=6&sort=popular"}/>
            </Suspense>
            <br />
            <br />
            <br />
            <div id="latest" className="title-box text-center">
                <h3 className="title-a">
                Latest Repos
                </h3>
                <p className="subtitle-a">
                What's cooking at cooperatives?
                </p>
                <div className="line-mf"/>
            </div>
            <Suspense fallback={<FullWidthSpinner/>}>
                <RepoList url={"/api/repos?limit=6&sort=latest"}/>
            </Suspense>
        </Container>
    </>;
};
export default HomePage
