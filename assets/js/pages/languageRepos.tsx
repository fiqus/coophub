import * as React from 'react';
import useFetch from 'fetch-suspense';
import {RouteComponentProps, useLocation} from 'react-router';
import {ApiResponse, Repo} from "../types";
import {Container, CardDeck} from "reactstrap";
import RepoCard from "../components/RepoCard";
import _ from "lodash";

type ReposResponse = ApiResponse<[Repo]>
type MatchParams = {
  lang: string
}

function languageRepos (lang: string | null) {
  const url = `/api/languages/${lang}`
  const response = useFetch(url) as ReposResponse;
  return response;
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

const LanguageReposPage: React.FC<RouteComponentProps<MatchParams>> = ({match}) => {
  const lang = match.params.lang;
  const repos = languageRepos(lang);

  return <>
    <Container className="pt-xl-5 result-repos-cards">
        <div className="title-box text-center">
            <h3 className="title-a">
                Language repos
            </h3>
            {resultsMessage(repos.data.length, lang)}
            <div className="line-mf"></div>
        </div>
        {_.chunk(repos.data, 3).map((row, i)=>
          <CardDeck key={i}>
              {row.map((repo, j)=><RepoCard repo={repo} key={i*10+j}/>)}
          </CardDeck>)}
    </Container>
  </>
}

export default LanguageReposPage;
