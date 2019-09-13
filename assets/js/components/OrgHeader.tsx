import React from 'react';
import GitHubButton from 'react-github-btn';
import {Container, Jumbotron, ButtonGroup, Button, CardLink, Row, Col} from "reactstrap";
import {GoLocation, GoLink, GoMail} from "react-icons/all";
import {Org} from "../types";

const OrgHeader:React.FC<{org: Org}> = ({org}) => {
    const imgStyle = {width: "200px"};
    const marginTop = {marginTop: "1.8%"};
    const marginLeft = {marginLeft: "-1.5%"};
    return (
        <Jumbotron>
            <Container fluid>
                <Row>
                    <Col xs={{size: 1.5, offset: 2}}>
                      <img style={imgStyle} src={org.avatar_url}/>
                    </Col>
                    <Col xs="auto">
                        <h1 className="display-4" style={marginTop}>{org.name}</h1>
                        <ButtonGroup style={marginLeft}>
                            <Button color="link">
                                <GoLocation/> { org.location }
                            </Button>
                            <Button color="link">
                                <GoMail/> { org.email }
                            </Button>
                            <Button color="link"> 
                                <CardLink href={org.blog}> 
                                    <GoLink/> { org.blog }
                                </CardLink>
                            </Button>
                        </ButtonGroup>
                        <p style={marginTop}>
                            <GitHubButton href={"https://github.com/" + org.login} data-size="large"
                                        data-show-count
                                        aria-label={"Follow @ " + org.login + " on GitHub"}>
                            Follow @{org.login}
                            </GitHubButton>
                        </p>
                    </Col>
                </Row>
                <Row>
                    
                </Row>
            </Container>
        </Jumbotron>
    );
};

export default OrgHeader;