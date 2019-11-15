import * as React from 'react';
import useFetch from 'fetch-suspense';
import {RouteComponentProps, useLocation} from 'react-router';
import {ApiResponse, Repo} from "../types";
import {Container, CardColumns} from "reactstrap";
import RepoCard from "../components/RepoCard";

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
        Repositories founded with <b>{query}</b> query
      </p>
    )
  }
  return (
    <p className="subtitle-a">
      No repositories founded with <b>{query}</b> query
    </p>
  )
}

const SearchResultsPage: React.FC<RouteComponentProps> = () => {
  const query = useQuery();
  const search = query.get("q");
  const repos = searchRepos(search);

  return <>
    <Container className="pt-xl-5">
        <div className="title-box text-center">
            <h3 className="title-a">
                Results
            </h3>
            {resultsMessage(repos.data.length, search)}
            <div className="line-mf"></div>
        </div>
        <CardColumns>
            {repos.data.map((repo, i) => (
                <RepoCard key={i} repo={repo}/>
            ))}
        </CardColumns>
    </Container>
  </>
}

export default SearchResultsPage;
