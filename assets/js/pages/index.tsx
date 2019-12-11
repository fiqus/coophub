import * as React from 'react';
import {Suspense} from 'react';
import {RouteComponentProps} from 'react-router-dom';
import {CardDeck, Card, CardHeader, CardBody, Container, Row, Button} from "reactstrap";
import useFetch from 'fetch-suspense';
import {ApiResponse, Repo, TotalLanguage, Topic} from "../types";
import RepoCard from "../components/RepoCard";
import FullWidthSpinner from "../components/FullWidthSpinner";
import LanguagesChart from '../components/LanguagesChart';
import _ from "lodash";

type LanguagesResponse = ApiResponse<[TotalLanguage]>;
type ReposResponse = ApiResponse<[Repo]>
type TopicsResponse = ApiResponse<[Topic]>
type urlProp = {url:string}

const RepoList: React.FC<urlProp> = ({url}) => {
    const response = useFetch(url) as ReposResponse;
    return <>
        {_.chunk(response.data, 3).map((row, i)=>
            <CardDeck key={i}>
                {row.map((repo, j)=><RepoCard repo={repo} key={i*10+j}/>)}
            </CardDeck>)}
    </>;
};


const HomePage: React.FC<RouteComponentProps> = ({history}) => {
    const languagesResponse = useFetch("/api/languages") as LanguagesResponse;
    const topics = useFetch("/api/topics") as TopicsResponse;
    const navigate = (url: string) =>{
        history.push(url);
    };

    return <>
        <Container className="pt-xl-5">
            <div className="title-box text-center">
                <h3 className="title-a">
                Popular Repos
                </h3>
                <p className="subtitle-a">
                Most popular repos from coops
                </p>
                <div className="line-mf"/>
            </div>
            <Suspense fallback={<FullWidthSpinner/>}>
                <RepoList url={"/api/repos?limit=6&sort=popular"}/>
            </Suspense>
            <br />
            <br />
            <br />
            <div id="latest" className="title-box text-center">
                <h3 className="title-a">
                Latest Repos
                </h3>
                <p className="subtitle-a">
                Follow the recently updated repos
                </p>
                <div className="line-mf"/>
            </div>
            <Suspense fallback={<FullWidthSpinner/>}>
                <RepoList url={"/api/repos?limit=6&sort=latest"}/>
            </Suspense>
            <br />
            <br />
            <br />
            <div className="title-box text-center">
                <h3 className="title-a">
                Languages
                </h3>
                <p className="subtitle-a">
                Search repositories by the used languages
                </p>
                <div className="line-mf"/>
            </div>
            <div>
                    {Object.keys(languagesResponse.data).map(lang => {
                        const color = _.sample(['info', 'primary', 'secondary']);
                        return (
                            <a href={'/languages/' + lang.toLowerCase()}>
                                <Button color={color} className="ml-md-1 mt-md-3">
                                    {lang}
                                </Button>
                            </a>
                        )
                    })}
            </div>
            <br />
            <br />
            <br />
            <div className="title-box text-center">
                <h3 className="title-a">
                Topics
                </h3>
                <p className="subtitle-a">
                Search repositories by topics
                </p>
                <div className="line-mf"/>
            </div>
            <div>
                {
                    topics.data.map((t: Topic, i) => <Button className="ml-md-1 mt-md-1" outline size="sm" key={i} onClick={()=>navigate(`/topics/${t.topic}`)}>
                        {t.topic}
                    </Button>)
                }
            </div>
            <br />
            <br />
            <br />
            <div className="title-box text-center">
                <h3 className="title-a">
                Some facts
                </h3>
                <p className="subtitle-a">
                With nice charts!
                </p>
                <div className="line-mf"/>
            </div>
            <Row>
                <Container className="col-6 mb-5">
                    <CardDeck>
                        <Card className="card card-blog mb-4">
                            <CardHeader style={{color: "grey"}}><h5>Most popular languages</h5></CardHeader>
                            <CardBody>
                                <LanguagesChart languages={languagesResponse}/>
                            </CardBody>
                        </Card>
                    </CardDeck>
                </Container>
            </Row>
        </Container>
    </>;
};
export default HomePage
