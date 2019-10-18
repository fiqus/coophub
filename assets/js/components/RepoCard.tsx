import React from 'react';
import {Card, CardHeader, CardBody, CardLink, CardText, CardFooter, Button} from "reactstrap";
import {GoRepoForked, GoStar} from "react-icons/all";
import {Repo} from "../types";
import Helpers from "../helpers";

const RepoCard:React.FC<{repo: Repo}> = ({repo}) => {
    return (
        <Card className="card card-blog">
            <CardHeader style={{color: "grey"}}><h5><a href={repo.html_url}>{repo.name}</a></h5></CardHeader>
            <CardBody>
                <div class="card-category-box">
                    <div class="card-category">
                        <h6 class="category">{Helpers.get_languages(repo.languages)}</h6>
                    </div>
                    
                </div>
                <CardText>{repo.fork ? "(fork) " : ""}{repo.description}</CardText>
            </CardBody>
            <CardFooter>
                <div class="post-author">
                    <a href={`orgs/${repo.key}`}>
                        <img src={repo.owner.avatar_url} alt="" class="avatar rounded-circle"/>
                        <span class="author">{repo.owner.login}</span>
                    </a>
                </div>
                <div class="post-date">
                    <CardLink href={`${repo.html_url}/fork`}><GoRepoForked/> {repo.forks_count}</CardLink>
                    <CardLink href={`${repo.html_url}/stargazers`}><GoStar/>{repo.stargazers_count}</CardLink>
                </div>
                
            </CardFooter>
        </Card>
    );
};

export default RepoCard;