export type ApiResponse<T> = {
    data: T;
}

export type Owner = {
    login: string;
    avatar_url: string;
}

export type Language = {
    lang: string,
    percentage: number
}

export type TotalLanguage = {
    [key: string]: {
        percentage: number
    }
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
    parent: {name:string, url:string}
}

export type Repos = Array<Repo>

export type Org = {
    yml_data: {
        name: string,
        location: string,
        source: string,
        url: string,
        description: string
    };
    key: string;
    name: string;
    description: string;
    location: string;
    html_url: string;
    avatar_url: string;
    blog: string;
    email: string;
    login: string;
    languages: Array<Language>;
    created_at: string;
    repo_count: number;
    star_count: number;
}

export type Counters = {
    orgs: number;
    repos: number;
};

export type Topic = {
    topic: string;
    count: number;
    orgs: Array<string>;
};

export type Topics = Array<Topic>;