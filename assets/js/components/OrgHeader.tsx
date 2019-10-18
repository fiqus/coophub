import React from 'react';
import GitHubButton from 'react-github-btn';
import {Container, Jumbotron, ButtonGroup, Button, CardLink, Row, Col} from "reactstrap";
import {GoLocation, GoLink, GoMail} from "react-icons/all";
import LanguageTag from './LanguageTag'; 
import {Org} from "../types";

const OrgHeader:React.FC<{org: Org, maxLanguages: number}> = ({org, maxLanguages}) => {
    const mainLanguages = org.languages.slice(0, maxLanguages);

    return (
        
        <Container>
            
            <div class="title-box text-center mt-5">
                <img className="center-block" src={org.avatar_url} alt="" className="rounded-circle b-shadow-a avatar_coop"/>
                <h3 className="title-a mt-4">
                {org.name}
                </h3>
                <p class="subtitle-a">
                {org.description}
                </p>
                <div class="line-mf mb-3"></div>
                <ButtonGroup>
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
                <br/>
                <ButtonGroup>
                    {mainLanguages.map(lang => <LanguageTag key={lang.lang} language={lang} />)}
                </ButtonGroup>
                <p className="mt-2">
                    <GitHubButton  href={"https://github.com/" + org.login} data-size="large"
                                data-show-count
                                aria-label={"Follow @ " + org.login + " on GitHub"}>
                    Follow @{org.login}
                    </GitHubButton>
                </p>
            </div>
            
        </Container>
        
    );
};

export default OrgHeader;