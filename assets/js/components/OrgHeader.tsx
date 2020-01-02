import React from 'react';
import {Container, ButtonGroup, Button, CardLink, Row, Col} from "reactstrap";
import {GoLocation, GoLink, GoMail, IoMdCalendar, GoMarkGithub} from "react-icons/all";
import {Org} from "../types";
import LanguagesProgressBar from './LanguagesProgressBar';
import CountUp from 'react-countup';
import {GoCode, GoStar} from "react-icons/all";

const OrgHeader:React.FC<{org: Org, maxLanguages: number, starsSum: number}> = ({org, maxLanguages, reposQuantity, starsSum}) => {
    const orgDate = new Date(org.created_at);
    const createdDate = `${orgDate.toLocaleString('en', { month: 'long' })} ${orgDate.getFullYear()}`
    
    return (
        
        <Container className="mt-5">
            <Row>
                <Container className="col-2">
                    <div className="counter-box mt-5">
                        <div className="counter-ico">
                            <span className="ico-circle"><GoStar/></span>
                        </div>
                        <div className="counter-num" >
                            <p className="counter"><CountUp end={starsSum}/></p>
                            <span className="counter-text">STARS</span>
                        </div>
                    </div>
                </Container>
                <Container className="col-8 text-center mb-0">
                    <img src={org.avatar_url} alt="" className="center-block rounded-circle b-shadow-a avatar_coop"/>
                    <h3 className="title-a mt-4">
                    {org.yml_data.name}
                    </h3>
                    <p className="subtitle-a">
                    {org.description}
                    </p>
                </Container>
                <Container className="col-2">
                    <div className="counter-box mt-5">
                        <div className="counter-ico">
                            <span className="ico-circle"><GoCode/></span>
                        </div>
                        <div className="counter-num" >
                            <p className="counter"><CountUp end={org.repo_count}/></p>
                            <span className="counter-text">REPOS</span>
                        </div>
                    </div>
                </Container>
            </Row>
            
            <div className="line-mf mb-3"/>
            <Row className="skill-mf">
                <LanguagesProgressBar languages={org.languages} maxLanguages={maxLanguages}></LanguagesProgressBar>
            </Row>

            <Container className="text-center mb-4">
                <Row className="justify-content-center">
                    {org.location &&
                        <Col xs="12"  sm="6" md="4" className="py-1">
                            <GoLocation/> { org.location }
                        </Col>
                    }
                    {org.email &&
                        <Col xs="12" sm="6" md="4" className="py-1">
                            <GoMail/> { org.email }
                        </Col>
                    }
                    {org.blog &&
                        <Col xs="12" sm="6" md="4" className="py-1">
                            <Button color="link" className="py-0">
                                <CardLink href={org.blog} target="_blank"> 
                                    <GoLink/> { org.blog }
                                </CardLink>
                            </Button>
                        </Col>
                    }
                    {org.login &&
                        <Col xs="12" sm="6" md="4" className="py-1">
                            <Button color="link" className="py-0">
                                <CardLink href={`https://github.com/${org.login}`} target="_blank"> 
                                    <GoMarkGithub/> { org.login }
                                </CardLink>
                            </Button>
                        </Col>
                    }
                    <Col xs="12" sm="6"  md="4" className="py-1">
                        <IoMdCalendar />
                        Created in {createdDate}
                    </Col>
                </Row>
            </Container>
        </Container>

    );
};

export default OrgHeader;