import React from 'react';
import {Card, CardHeader, CardBody, CardLink, CardText, CardFooter, Button} from "reactstrap";
import {GoRepoForked, GoStar} from "react-icons/all";
import {Repo} from "../types";
import getLangColor from '../languageColors';
import Emoji from "react-emoji-render";


const RepoCard:React.FC<{repo: Repo}> = ({repo}) => {
    const langs = repo.languages.filter(l => l.percentage > 30).sort((a,b)=>b.percentage - a.percentage).map(l => l.lang);
    const langColors = (langs.length == 1?[langs[0], langs[0]]:langs).map(l=>getLangColor(l)).join(",");

    return (
        <Card className="card card-blog mb-4">
            <CardHeader style={{color: "grey"}}><h5><a href={repo.html_url} target="_blank">{repo.name}</a></h5></CardHeader>
            <CardBody>
                {langs.length ?
                    <div className="card-category-box">
                        <div className="card-category-border"
                        style={{background: `linear-gradient(to bottom right, ${langColors})`}}>
                            <div className="card-category">
                                <h6 className="category">{langs.join(" + ")}</h6>
                            </div>

                        </div>
                    </div>
                : ""}
                <CardText>
                    {repo.fork && repo.parent ? <a href={repo.parent.url} target="_blank" className="card-fork"><GoRepoForked/>{repo.parent.name}</a> : ""}
                    {repo.description ? <Emoji text={repo.description}/> : <i>- no description -</i>}
                </CardText>
            </CardBody>
            <CardFooter>
                <div className="post-author">
                    <a href={`/orgs/${repo.key}`}>
                        <img src={repo.owner.avatar_url} alt="" className="avatar rounded-circle"/>
                        <span className="author">{repo.owner.login}</span>
                    </a>
                </div>
                <div className="post-date">
                    <CardLink href={`${repo.html_url}/fork`} target="_blank"><GoRepoForked/> {repo.forks_count}</CardLink>
                    <CardLink href={`${repo.html_url}/stargazers`} target="_blank"><GoStar/>{repo.stargazers_count}</CardLink>
                </div>
                
            </CardFooter>
        </Card>
    );
};

export default RepoCard;