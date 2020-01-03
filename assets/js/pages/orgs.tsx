import * as React from 'react';
import {Container, CardColumns, Card, CardImg, ListGroup, ListGroupItem, Row, Col} from "reactstrap";
import {ApiResponse, Org} from "../types";
import useFetch from 'fetch-suspense';
import _ from "lodash";
import RepoCard from '../components/RepoCard';
import { Link } from 'react-router-dom';
import { GoLocation } from 'react-icons/go';

type OrgsResponse = ApiResponse<Array<Org>>

const OrgList: React.FC = () => {
    const response = useFetch('/api/orgs/') as OrgsResponse;
    return <ListGroup className="coop-list-item mb-5">
        {_.sortBy(response.data, o=>o.yml_data.name.toUpperCase()).map((org, i) => <ListGroupItem key={i} tag={Link} to={`/orgs/${org.key}`}>
            <Row>
                <Col md="6" className="org-name">
                    <img src={org.avatar_url} alt="" className="avatar rounded-circle"/>
                    <span>{org.yml_data.name}</span>
                </Col>
                <Col md="2" className="org-details">
                    <span>{org.repo_count} Repos</span>
                </Col>
                <Col className="org-location">
                {org.location &&
                    <span>
                        <GoLocation/> { org.location }
                    </span>
                } 
                </Col>
            </Row>
        </ListGroupItem>)}
    </ListGroup>;
};

const OrgsPage: React.FC = () => {
    return <>   
        <Container className="pt-md-5">
            <div className="title-box text-center">
                <h3 className="title-a">
                Cooperatives
                </h3>
                <p className="subtitle-a">
                These are the cooperatives sharing their code with the world.
                </p>
                <div className="line-mf"/>
            </div>
            <OrgList/>
        </Container>
    </>
};
export default OrgsPage;
