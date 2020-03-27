import * as React from "react";

declare var APP_VERSION: string;

const Footer: React.FC = () =>
    <footer className="mt-xl-5">
        <div className="container">
            <div className="row">
                <div className="col-sm-12">
                    <div className="copyright-box">
                        <div className="credits">
                        <a className="btn btn-link" href="https://fiqus.coop" target="_blank">Created with ♥ by Fiqus</a>
                        &nbsp;|&nbsp;
                        <a className="btn btn-link" href="https://github.com/fiqus/coophub" target="_blank">View the GitHub repo</a>
                        &nbsp;|&nbsp;
                        <a className="btn btn-link" href={`https://github.com/fiqus/coophub/releases/tag/v${APP_VERSION}`} target="_blank">v{APP_VERSION}</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </footer>;

export default Footer;