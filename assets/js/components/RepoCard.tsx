import React from 'react';
import {Card, CardHeader, CardBody, CardLink, CardText, CardFooter, Button} from "reactstrap";
import {GoRepoForked, GoStar} from "react-icons/all";
import {Repo} from "../types";
import Helpers from "../helpers";

const RepoCard:React.FC<{repo: Repo}> = ({repo}) => {
    const langs = Helpers.list_languages(repo.languages);

    return (
        <Card className="card card-blog mb-4">
            <CardHeader style={{color: "grey"}}><h5><a href={repo.html_url}>{repo.name}</a></h5></CardHeader>
            <CardBody>
                {langs &&
                    <div className="card-category-box">
                        <div className="card-category">
                            <h6 className="category">{langs}</h6>
                        </div>
                    </div>
                }
                <CardText>{repo.fork ? "(fork) " : ""}{repo.description || <i>- no description -</i>}</CardText>
            </CardBody>
            <CardFooter>
                <div className="post-author">
                    <a href={`/orgs/${repo.key}`}>
                        <img src={repo.owner.avatar_url} alt="" className="avatar rounded-circle"/>
                        <span className="author">{repo.owner.login}</span>
                    </a>
                </div>
                <div className="post-date">
                    <CardLink href={`${repo.html_url}/fork`}><GoRepoForked/> {repo.forks_count}</CardLink>
                    <CardLink href={`${repo.html_url}/stargazers`}><GoStar/>{repo.stargazers_count}</CardLink>
                </div>
                
            </CardFooter>
        </Card>
    );
};

export default RepoCard;