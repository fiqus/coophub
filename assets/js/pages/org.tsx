import * as React from 'react';
import {RouteComponentProps} from 'react-router';
import GitHubButton from 'react-github-btn';
import {CardColumns, Container, Jumbotron, NavLink, Spinner} from "reactstrap";
import RepoCard from "../components/RepoCard";
import {fetchOrg} from "../api";
import {Org} from "../types";

type State = {
    org: Org;
    loading: boolean;
}

type MatchParams = {
    name: string
}

export default class OrgPage extends React.Component<{}, State> {
    readonly orgName: string;

    constructor(props: RouteComponentProps<MatchParams>) {
        super(props);
        this.state = {org: {name: "", location: "", description: "", repos: []}, loading: true};
        this.orgName = props.match.params.name;

        fetchOrg(this.orgName).then(response => {
            this.setState({org: response.data, loading: false});
        }).catch(() => {
            props.history.push('/')
        });
    }

    public render(): JSX.Element {
        return (
            <>
                <Jumbotron fluid>
                    <Container fluid>
                        <h1 className="display-3">{this.state.org.name}</h1>
                        <p className="lead">{this.state.org.description}</p>
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
                    {this.state.loading ?
                        <Spinner style={{width: '3rem', height: '3rem'}}/> :
                        <CardColumns>
                            {this.state.org.repos.map((repo, i) => (
                                <RepoCard key={i} repo={repo}/>
                            ))}
                        </CardColumns>}
                    <p>
                        <NavLink to="/">Back to home</NavLink>
                    </p>
                </Container>

            </>
        )
    }
}