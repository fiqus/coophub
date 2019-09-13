export type ApiResponse<T> = {
    data: T;
}

export type Owner = {
    login: string;
}

export type Repo  = {
    description: string;
    name: string;
    stargazers_count: number;
    forks_count: number;
    html_url: string;
    owner: Owner;
}

export type Repos = Array<Repo>

export type Org = {
    location: string;
    name: string;
    description: string;
    avatar_url: string;
    blog: string;
    email: string;
    login: string;
}