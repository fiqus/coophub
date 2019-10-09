import React from 'react';
import {Card, CardHeader, CardBody, CardLink, CardText, CardTitle, CardFooter, Button} from "reactstrap";
import {GoRepoForked, GoStar} from "react-icons/all";
import {Repo} from "../types";
import Helpers from "../helpers";

const RepoCardIndex:React.FC<{repo: Repo}> = ({repo}) => {
    return (
        <Card>
            <CardHeader style={{color: "grey"}}><a href={`orgs/${repo.key}`}>{repo.owner.login}</a></CardHeader>
            <CardBody>
                <CardTitle><h3><a href={repo.html_url}>{repo.name}</a></h3></CardTitle>
                <CardText>{repo.fork ? "(fork) " : ""}{repo.description}</CardText>
                <CardText>
                    <small className="text-muted">{Helpers.get_languages(repo.languages)}</small>
                </CardText>
            </CardBody>
            <CardFooter>
                <CardLink href={`${repo.html_url}/fork`}><GoRepoForked/> {repo.forks_count}</CardLink>
                <CardLink href={`${repo.html_url}/stargazers`}><GoStar/>{repo.stargazers_count}</CardLink>
            </CardFooter>
        </Card>
    );
};

export default RepoCardIndex;