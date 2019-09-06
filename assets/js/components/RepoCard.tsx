import React from 'react';
import {Card, CardBody, CardLink, CardText, CardTitle} from "reactstrap";
import {GoRepoForked, GoStar} from "react-icons/all";
import {Repo} from "../types";

const RepoCard:React.FC<{repo: Repo}> = ({repo}) => {
    return (
        <Card>
            {/*<CardImg top width="100%" src="https://placeholdit.imgix.net/~text?txtsize=33&txt=318%C3%97180&w=318&h=180" alt="Card image cap" />*/}
            <CardBody>
                <CardTitle><h3><a href={repo.html_url}>{repo.name}</a></h3></CardTitle>
                <CardText>{repo.description}</CardText>
                <CardLink href={`${repo.html_url}/fork`}><GoRepoForked/> {repo.forks_count}</CardLink>
                <CardLink href={repo.html_url}><GoStar/>{repo.stargazers_count}</CardLink>
            </CardBody>
        </Card>
    );
};

export default RepoCard;