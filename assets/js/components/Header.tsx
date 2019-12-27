import * as React from 'react';
import {Suspense, useState} from 'react';
import {Link, RouteComponentProps, withRouter} from "react-router-dom";
import {
    Collapse,
    DropdownItem,
    DropdownMenu,
    DropdownToggle,
    Nav,
    Navbar,
    NavbarBrand,
    NavbarToggler,
    NavItem, NavLink,
    UncontrolledDropdown,
    Input
} from "reactstrap";
import useFetch from 'fetch-suspense';
import {ApiResponse, Org, Topic} from "../types";

const Header: React.FC<RouteComponentProps> = ({history}) => {
    const [collapsed, setCollapsed] = useState(true);
    const toggleNavBar = () => {
        setCollapsed(!collapsed);
    };
    const parseSearchQuery = () => {
        return (new URLSearchParams(location.search)).get("q") || "";
    }
    const navigate = (url: string) =>{
        history.push(url);
    };

    return <Navbar className="navbar-reduce navbar-b navbar-trans navbar-expand-md fixed-top">
        <NavbarBrand to="/" tag={Link} className="js-scroll" >
            <img id="logo" src="/images/logo-light.png" alt=""/>
        </NavbarBrand>
        <NavbarToggler onClick={toggleNavBar}/>
        <Collapse isOpen={!collapsed} navbar>
            <span className="slogan">Repos from cooperatives around the world!</span>
            <form action="/search" method="get" className="ml-auto search-form">
                <Input name="q" placeholder="Search repos, coops or technologies" defaultValue={parseSearchQuery()}/>
            </form>
            <Nav className="ml-auto" navbar>
                <NavItem>
                    <NavLink tag={Link} to={`/orgs/`}>Cooperatives</NavLink>
                </NavItem>
                <NavItem>
                    <NavLink href="https://github.com/fiqus/coophub#add-your-co-operative" target="_blank">How to join?</NavLink>
                </NavItem>
            </Nav>
        </Collapse>
    </Navbar>
};

export default withRouter(Header)
