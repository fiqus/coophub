import * as React from "react";
import {Org} from "./types";


export interface ApiResponse<T> {
    data: T;
}

export function fetchOrg(orgName: string): Promise<ApiResponse<Org>>{
    return fetch(`/api/orgs/${orgName}`).then(response => response.json() as Promise<ApiResponse<Org>>);
}

export function fetchLatesRepos(): Promise<ApiResponse<Org>>{
    return fetch('/api/repos/latest').then(response => response.json() as Promise<ApiResponse<Org>>);
}