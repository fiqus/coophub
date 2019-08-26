// pages/org.tsx

import * as React from 'react';
import {Redirect, RouteComponentProps} from 'react-router';
import Main from '../components/Main';
import GitHubButton from 'react-github-btn';
import {
    Card,
    CardBody, CardColumns, CardLink,
    CardText,
    CardTitle,
    Col, Container, Jumbotron, NavLink,
    Row,
    Spinner
} from "reactstrap";
import {GoRepoForked, GoStar} from 'react-icons/go';

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
    description: string;
    name: string;
    stargazers_count: number;
    forks_count: number;
    html_url: string;
}

interface OrgExampleState {
    Org: Org;
    loading: boolean;
}

interface MatchParams {
    name: string
}

export default class OrgPage extends React.Component<{}, OrgExampleState> {
    readonly orgName: string;

    constructor(props: RouteComponentProps<MatchParams>) {
        super(props);
        this.state = {Org: {name: "", location: "", description: "", repos: []}, loading: true};
        this.orgName = props.match.params.name;

        // Get the data from our API.
        fetch(`/api/orgs/${this.orgName}`)
            .then(response => response.json() as Promise<ApiResponse>)
            .then(response => {
                this.setState({Org: response.data, loading: false});
            })
            .catch(() => {
                return (<Redirect to="/"/>);
            });
    }

    private static renderReposGrid(repos: Repo[]) {
        return (
            <CardColumns>
                {repos.map(repo => (
                    <Card>
                        {/*<CardImg top width="100%" src="https://placeholdit.imgix.net/~text?txtsize=33&txt=318%C3%97180&w=318&h=180" alt="Card image cap" />*/}
                        <CardBody>
                            <CardTitle>{repo.name}</CardTitle>
                            <CardText>{repo.description}</CardText>
                            <CardLink href={`${repo.html_url}/fork`}><GoRepoForked/> {repo.forks_count}</CardLink>
                            <CardLink href={repo.html_url}><GoStar/>{repo.stargazers_count}</CardLink>
                        </CardBody>
                    </Card>
                ))}
            </CardColumns>
        );
    }

    public render(): JSX.Element {
        const content = this.state.loading ? (
            <Spinner style={{width: '3rem', height: '3rem'}}/>
        ) : (
            OrgPage.renderReposGrid(this.state.Org.repos)
        );

        return (
            <>
                <Jumbotron fluid>
                    <Container fluid>
                        <h1 className="display-3">{this.state.Org.name}</h1>
                        <p className="lead">{this.state.Org.description}</p>
                        <p className="lead">
                            <GitHubButton href={"https://github.com/" + this.orgName} data-size="large"
                                          data-show-count
                                          aria-label={"Follow @ " + this.orgName + " on GitHub"}>
                                Follow @{this.orgName}
                            </GitHubButton>
                        </p>
                    </Container>
                </Jumbotron>
                <Container>
                    {content}
                    <br/>
                    <br/>
                    <p>
                        <NavLink to="/">Back to home</NavLink>
                    </p>
                </Container>

            </>
        )
    }
}