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
    UncontrolledDropdown
} from "reactstrap";
import useFetch from 'fetch-suspense';
import {ApiResponse, Org} from "../types";

type OrgsResponse = ApiResponse<[Org]>

type CoopListProps = {
    navigate: (url: string) => void;
}

const fetchAndSortOrgs = () => {
    const response = useFetch('/api/orgs') as OrgsResponse;
    return Object.values(response.data).sort((a, b) => (a.name.toLowerCase() <= b.name.toLowerCase()) ? -1 : 1);
};

const CoopList: React.FC<CoopListProps> = ({navigate}) => {
    const orgs = fetchAndSortOrgs();
    return <>
        {orgs.map((org, i) => <DropdownItem key={i} onClick={()=>navigate(`/orgs/${org.key}`)}>
            {org.name}
        </DropdownItem>)}
    </>
};


const Header: React.FC<RouteComponentProps> = ({history}) => {

    const [collapsed, setCollapsed] = useState(true);
    const toggleNavBar = () => {
        setCollapsed(!collapsed);
    };

    const navigate = (url: string) =>{
        history.push(url);
    };

    return <Navbar className="navbar-reduce navbar-b navbar-trans navbar-expand-md fixed-top">
        <NavbarBrand to="/" tag={Link} className="js-scroll" >
            <img id="logo" src="/images/coophub.png" alt=""/>
            CoopHub
        </NavbarBrand>
        <NavbarToggler onClick={toggleNavBar}/>
        <Collapse isOpen={!collapsed} navbar>
            <Nav className="ml-auto" navbar>
                <UncontrolledDropdown nav inNavbar>
                    <DropdownToggle nav caret>
                        Coops
                    </DropdownToggle>
                    <DropdownMenu right>
                        <Suspense fallback={<DropdownItem>Loading...</DropdownItem>}>
                            <CoopList navigate={navigate}/>
                        </Suspense>
                    </DropdownMenu>
                </UncontrolledDropdown>
            </Nav>
        </Collapse>
    </Navbar>
};

export default withRouter(Header)
