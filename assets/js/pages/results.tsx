import * as React from 'react';
import useFetch from 'fetch-suspense';
import {RouteComponentProps} from 'react-router';
import {Container, CardColumns} from "reactstrap";
import {ApiResponse, Repo, Topic} from "../types";
import RepoCard from "../components/RepoCard";

type ReposResponse = ApiResponse<[Repo]>

function searchRepos (topic: Topic) {
    const url = `/api/search?topic=${topic}`
    const response = useFetch(url) as ReposResponse;
    return response;
}

type MatchParams = {
    topic: string
}

const ResultsPage: React.FC<RouteComponentProps<MatchParams>> = ({match}) => {
    const topic = match.params.topic;
    const repos = searchRepos(topic);

    return <>
        <Container className="pt-xl-5">
            <div className="title-box text-center">
                <h3 className="title-a">
                    {topic} Repos
                </h3>
                <p className="subtitle-a">
                    Repositories by {topic} topic
                </p>
                <div className="line-mf"></div>
            </div>
            <CardColumns>
                {repos.data.map((repo, i) => (
                    <RepoCard key={i} repo={repo}/>
                ))}
            </CardColumns>
        </Container>
    </>
};
export default ResultsPage;
