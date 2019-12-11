import 'bootstrap/dist/css/bootstrap.css';
import '../css/theme.css';
import '../css/app.css';
//import '../css/charts.css'; @TODO Breaks all the styles! And search inside for: NOT FOUND.. breaks webpack build!

import 'phoenix_html';

import * as React from 'react';
import * as ReactDOM from 'react-dom';
import Root from './Root';

// This code starts up the React app when it runs in a browser. It sets up the routing
// configuration and injects the app into a DOM element.
ReactDOM.render(<Root/>, document.getElementById('react-app'));