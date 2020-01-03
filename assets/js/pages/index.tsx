import * as React from 'react';
import {Suspense} from 'react';
import {RouteComponentProps, Link} from 'react-router-dom';
import {CardDeck, Card, CardHeader, CardBody, Container, Row, Button} from "reactstrap";
import useFetch from 'fetch-suspense';
import {ApiResponse, Repo, Counters, TotalLanguage, Topic} from "../types";
import RepoCard from "../components/RepoCard";
import FullWidthSpinner from "../components/FullWidthSpinner";
import LanguagesChart from '../components/LanguagesChart';
import _ from "lodash";
import getLangColor from '../languageColors';
import CountUp from 'react-countup';
import {GoGlobe, GoCode} from "react-icons/all";
import { mostReadable, TinyColor} from '@ctrl/tinycolor';


type CountersResponse = ApiResponse<Counters>;
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


const HomePage: React.FC<RouteComponentProps> = () => {
    const countersResponse = useFetch("/api/counters") as CountersResponse;
    const languagesResponse = useFetch("/api/languages") as LanguagesResponse;
    const topics = useFetch("/api/topics") as TopicsResponse;

    return <>
        <Container className="mt-5">
            <Row>
                <Container className="col-2 mt-2">
                    <div className="counter-box">
                        <div className="counter-ico">
                            <span className="ico-circle"><GoGlobe/></span>
                        </div>
                        <div className="counter-num">
                            <p className="counter"><CountUp end={countersResponse.data.orgs}/></p>
                            <span className="counter-text">COOPS</span>
                        </div>
                    </div>
                </Container>
                <Container className="col-8 title-box text-center">
                    <h3 className="title-a">
                    Popular Repos
                    </h3>
                    <p className="subtitle-a">
                    Most popular repos from coops
                    </p>
                    <div className="line-mf"/>
                </Container>
                <Container className="col-2 mt-2">
                    <div className="counter-box">
                        <div className="counter-ico">
                            <span className="ico-circle"><GoCode/></span>
                        </div>
                        <div className="counter-num">
                            <p className="counter"><CountUp end={countersResponse.data.repos}/></p>
                            <span className="counter-text">REPOS</span>
                        </div>
                    </div>
                </Container>
            </Row>
            <Suspense fallback={<FullWidthSpinner/>}>
                <RepoList url={"/api/repos?limit=6&sort=popular&exclude_forks=true"}/>
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
                <RepoList url={"/api/repos?limit=6&sort=latest&exclude_forks=true"}/>
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
            <div className="language-button-container">
                    {Object.keys(languagesResponse.data).map(lang => {
                        const color = getLangColor(lang);
                        const readable = (mostReadable(color, ["#111", "#555", "#CCC", "#eee"]) || new TinyColor("#000")).toHexString();
                        return (
                            <Button key={lang} tag={Link} style={{backgroundColor: color, color: readable}} to={'/languages/' + lang.toLowerCase()}>
                                 {lang} 
                            </Button>
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
            <div className="topic-button-container">
                {
                    topics.data.map((t: Topic, i) => 
                    <Button tag={Link} outline size="sm" key={i} to={`/topics/${t.topic}`}>
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
