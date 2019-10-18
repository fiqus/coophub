import * as React from 'react';
import {RouteComponentProps} from 'react-router';
import {CardColumns, Container} from "reactstrap";
import RepoCard from "../components/RepoCard";
import OrgHeader from "../components/OrgHeader";
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
    const repos = useFetch(`/api/orgs/${orgName}/repos?sort=popular`) as OrgReposResponse;
    const org = response.data;
    const maxLanguages = 5;

    return <>
        <OrgHeader org={org} maxLanguages={maxLanguages}/>
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
