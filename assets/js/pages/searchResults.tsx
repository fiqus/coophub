import * as React from 'react';
import useFetch from 'fetch-suspense';
import {RouteComponentProps, useLocation} from 'react-router';
import {ApiResponse, Repo} from "../types";
import {Container, CardDeck} from "reactstrap";
import RepoCard from "../components/RepoCard";
import _ from "lodash";

type ReposResponse = ApiResponse<[Repo]>

function searchRepos (query: string | null) {
  const url = `/api/search?q=${query}`
  const response = useFetch(url) as ReposResponse;
  return response;
}

// A custom hook that builds on useLocation to parse
// the query string for you.
function useQuery() {
  return new URLSearchParams(useLocation().search);
}

function resultsMessage(resultsLength: number, query: string | null) {
  if (resultsLength) {
    return (
      <p className="subtitle-a">
        Found <b>{resultsLength}</b> repositories for <b>{query}</b>
      </p>
    )
  }
  return (
    <p className="subtitle-a">
      No repositories found for <b>{query}</b>
    </p>
  )
}

const SearchResultsPage: React.FC<RouteComponentProps> = () => {
  const query = useQuery();
  const search = query.get("q");
  const repos = searchRepos(search);

  return <>
    <Container className="pt-md-5 result-repos-cards">
        <div className="title-box text-center">
            <h3 className="title-a">
                Search results
            </h3>
            {resultsMessage(repos.data.length, search)}
            <div className="line-mf"></div>
        </div>
        {_.chunk(repos.data, 3).map((row, i)=>
          <CardDeck key={i}>
              {row.map((repo, j)=><RepoCard repo={repo} key={i*10+j}/>)}
          </CardDeck>)}
    </Container>
  </>
}

export default SearchResultsPage;
