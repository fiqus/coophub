import * as React from 'react';
import {Suspense} from 'react';
import {RouteComponentProps} from 'react-router-dom';
import {CardDeck, Card, CardHeader, CardBody, Container, Row, Button} from "reactstrap";
import useFetch from 'fetch-suspense';
import {ApiResponse, Repo, TotalLanguage} from "../types";
import RepoCard from "../components/RepoCard";
import FullWidthSpinner from "../components/FullWidthSpinner";
import LanguagesChart from '../components/LanguagesChart';
import FakeChart from '../components/FakeChart'; 
import _ from "lodash";

type LanguagesResponse = ApiResponse<[TotalLanguage]>;
type ReposResponse = ApiResponse<[Repo]>
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
    const languagesResponse = useFetch("/api/languages") as LanguagesResponse;
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
                What's cooking at cooperatives?
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
                Search repositories by the technologies we use
                </p>
                <div className="line-mf"/>
            </div>
            <div>
                    {Object.keys(languagesResponse.data).map(lang => {
                        const color = _.sample(['info', 'primary', 'secondary']);
                        return (
                            <a href={'/search?q=' + lang}>
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
                Some facts
                </h3>
                <p className="subtitle-a">
                With nice charts!
                </p>
                <div className="line-mf"/>
            </div>
            <Row>
                <Container className="col-12 mb-5">
                    <CardDeck>
                        <Card className="card card-blog mb-4">
                            <CardHeader style={{color: "grey"}}><h5>Most popular languages</h5></CardHeader>
                            <CardBody>
                                <LanguagesChart languages={languagesResponse}/>
                            </CardBody>
                        </Card>
                        <Card className="card card-blog mb-4">
                            <CardHeader style={{color: "grey"}}><h5>Commits per month</h5></CardHeader>
                            <CardBody>
                                <FakeChart/>
                            </CardBody>
                        </Card>
                    </CardDeck>
                </Container>
            </Row>
        </Container>
    </>;
};
export default HomePage
