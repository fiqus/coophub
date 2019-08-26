import * as React from 'react';
import {useState} from "react";
import {NavLink} from "react-router-dom";
import {Collapse, Nav, Navbar, NavbarBrand, NavbarToggler, NavItem} from "reactstrap";

const Header: React.FC = () => {

    const [collapsed, setCollapsed] = useState(true);
    const toggleNavBar = ()=>{
        setCollapsed(!collapsed);
    };


    return <Navbar color="faded" light>
        <NavbarBrand href="/" className="mr-auto">coophub</NavbarBrand>
        <NavbarToggler onClick={toggleNavBar} className="mr-2" />
        <Collapse isOpen={!collapsed} navbar>
            <Nav navbar>
                {/*<NavItem>*/}
                {/*    <NavLink to="/components/">Components</NavLink>*/}
                {/*</NavItem>*/}
                {/*<NavItem>*/}
                {/*    <NavLink to="https://github.com/reactstrap/reactstrap">GitHub</NavLink>*/}
                {/*</NavItem>*/}
            </Nav>
        </Collapse>
    </Navbar>
};

export default Header
