export type Repo  = {
    description: string;
    name: string;
    stargazers_count: number;
    forks_count: number;
    html_url: string;
}

export type Org = {
    location: string;
    name: string;
    description: string;
    repos: Repo[];
}