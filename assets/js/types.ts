export type ApiResponse<T> = {
    data: T;
}

export type Owner = {
    login: string;
    avatar_url: string;
}

export type Language = {
    lang: string,
    bytes: number,
    percentage: number
}

export type Repo  = {
    key: string;
    description: string;
    name: string;
    stargazers_count: number;
    forks_count: number;
    html_url: string;
    owner: Owner;
    languages: Array<Language>;
    fork: boolean;
}

export type Repos = Array<Repo>

export type Org = {
    key: string;
    name: string;
    description: string;
    location: string;
    avatar_url: string;
    blog: string;
    email: string;
    login: string;
    languages: Array<Language>;
}

export type Topic = string;

export type Topics = Array<Topic>;