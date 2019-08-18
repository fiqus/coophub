// pages/org.tsx

import * as React from 'react';
import { Redirect } from 'react-router';
import { Link } from 'react-router-dom';

import Main from '../components/Main';
import GitHubButton from 'react-github-btn';

// The interface for our API response
interface ApiResponse {
  data: Org;
}

// The interface for our Org model.
interface Org {
  location: string;
  name: string;
  description: string;
  repos: Repo[];
}

interface Repo {
  name: string;
  stargazers_count: number;
  forks_count: number;
  html_url: string;
}

interface OrgExampleState {
  Org: Org;
  loading: boolean;
}

export default class OrgPage extends React.Component<
  {},
  OrgExampleState
> {
  constructor(props: {}) {
    super(props);
    this.state = { Org: {name: "", location: "", description: "", repos: []}, loading: true };
    this.orgName = props.match.params.name;

    // Get the data from our API.
    fetch(`/api/orgs/${this.orgName}`)
      .then(response => response.json() as Promise<ApiResponse>)
      .then(response => {
        this.setState({ Org: response.data, loading: false });
      })
      .catch(err => {
        return (<Redirect to = "/" />);
      });
  }

  private static renderReposGrid(repos: Repo[]) {
    return (
      <div>
      {repos.map(repo => (
        <div key={repo.name}>
          <div>
            <a href={repo.html_url}>{repo.name}</a>
            <span>
            <GitHubButton href={repo.html_url} data-icon="octicon-star" aria-label="Star fiqus/repo on GitHub">{repo.stargazers_count}</GitHubButton>
            </span>
            <span>
            <GitHubButton href={repo.html_url + "/fork"} data-icon="octicon-repo-forked" aria-label="Fork fiqus/repo on GitHub">{repo.forks_count}</GitHubButton>
            </span>
          </div>
          <div>{repo.description}</div>
        </div>
      ))}
      </div>
    );
  }

  public render(): JSX.Element {
    const content = this.state.loading ? (
      <p>
        <em>Loading...</em>
      </p>
    ) : (
      OrgPage.renderReposGrid(this.state.Org.repos)
    );
    
    return (
      <Main>
        <h1>{this.state.Org.name} <GitHubButton href={"https://github.com/" + this.orgName} data-size="large" data-show-count="true" aria-label={"Follow @" + this.orgName + " on GitHub"}>Follow @{this.orgName}</GitHubButton></h1>
        <p>
        {this.state.Org.description}
        </p>
        {content}
        <br />
        <br />
        <p>
          <Link to="/">Back to home</Link>
        </p>
      </Main>
    );
  }
}