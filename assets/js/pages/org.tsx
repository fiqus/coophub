import * as React from 'react';
import {RouteComponentProps} from 'react-router';
import GitHubButton from 'react-github-btn';
import {CardColumns, Container, Jumbotron, NavLink} from "reactstrap";
import RepoCard from "../components/RepoCard";
import {ApiResponse, Org, Repos} from "../types";
import useFetch from 'fetch-suspense';


type MatchParams = {
    name: string
}
type OrgResponse = ApiResponse<Org>
type OrgReposResponse = ApiResponse<Repos>


const OrgPage: React.FC<RouteComponentProps<MatchParams>> = ({match}) => {
    const orgName = match.params.name;
    const response = useFetch(`/api/orgs/${orgName}`) as OrgResponse;
    const repos = useFetch(`/api/orgs/${orgName}/repos`) as OrgReposResponse;
    const org = response.data;

    return <>
        <Jumbotron fluid>
            <Container fluid>
                <h1 className="display-3">{org.name}</h1>
                <p className="lead">{org.description}</p>
                <p className="lead">
                    <GitHubButton href={"https://github.com/" + orgName} data-size="large"
                                  data-show-count
                                  aria-label={"Follow @ " + orgName + " on GitHub"}>
                        Follow @{orgName}
                    </GitHubButton>
                </p>
            </Container>
        </Jumbotron>
        <Container>
            <CardColumns>
                {repos.data.map((repo, i) => (
                    <RepoCard key={i} repo={repo}/>
                ))}
            </CardColumns>
        </Container>
    </>
};
export default OrgPage;
