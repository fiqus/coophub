import * as React from 'react';
import {RouteComponentProps} from 'react-router';
import {CardDeck, Container} from "reactstrap";
import RepoCard from "../components/RepoCard";
import OrgHeader from "../components/OrgHeader";
import {ApiResponse, Org, Repos} from "../types";
import useFetch from 'fetch-suspense';
import _ from "lodash";


type MatchParams = {
    name: string
}
type OrgResponse = ApiResponse<Org>
type OrgReposResponse = ApiResponse<Repos>


const OrgPage: React.FC<RouteComponentProps<MatchParams>> = ({match}) => {
    const orgName = match.params.name;
    const response = useFetch(`/api/orgs/${orgName}`) as OrgResponse;
    const repos = useFetch(`/api/orgs/${orgName}/repos?sort=popular`) as OrgReposResponse;
    const starsSum = repos.data.reduce((acc, r)=>{
        return acc + r.stargazers_count;
    }, 0);
    const org = response.data;
    const maxLanguages = 5;

    return <>
        <OrgHeader org={org} maxLanguages={maxLanguages} reposQuantity={repos.data.length} starsSum={starsSum}/>
        <Container className="org-repos-cards">
            {_.chunk(repos.data, 3).map((row, i)=>
            <CardDeck key={i}>
                {row.map((repo, j)=><RepoCard repo={repo} key={i*10+j}/>)}
            </CardDeck>)}
        </Container>
    </>
};
export default OrgPage;
