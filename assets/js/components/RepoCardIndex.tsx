import React from 'react';
import {Card, CardHeader, CardBody, CardLink, CardText, CardTitle, CardFooter, Button} from "reactstrap";
import {GoRepoForked, GoStar} from "react-icons/all";
import {Repo} from "../types";

const RepoCardIndex:React.FC<{repo: Repo}> = ({repo}) => {
    return (
        <Card>
            <CardHeader style={{color: "grey"}}>{repo.owner.login}</CardHeader>
            <CardBody>
                <CardTitle><h3><a href={repo.html_url}>{repo.name}</a></h3></CardTitle>
                <CardText>{repo.description}</CardText>
            </CardBody>
            <CardFooter>
                <CardLink href={`${repo.html_url}/fork`}><GoRepoForked/> {repo.forks_count}</CardLink>
                <CardLink href={repo.html_url}><GoStar/>{repo.stargazers_count}</CardLink>
            </CardFooter>
        </Card>
    );
};

export default RepoCardIndex;