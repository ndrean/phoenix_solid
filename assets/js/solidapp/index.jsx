import { lazy } from "solid-js";
import { Router, Route, Routes, A } from "@solidjs/router";
import BauSolidCss from "bau-solidcss";

import context from "./context";
import { active, inactive } from "./indexCss.js";

// import styles from "./App.module.css";
// import "./index.css";

const { styled, createGlobalStyles } = BauSolidCss();

createGlobalStyles`
  body {
      margin: 0;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
        'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
        sans-serif;
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
  }
  
  code {
    font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
      monospace;
  }
`;

const Nav = (props) => styled("nav", props)`
  background-color: #282c34;
  padding: 1em;
  display: flex;
`;

function app(ctx) {
  history.pushState("", "", "/");
  const Home = lazy(() => import("./Home"));
  const Comp1 = lazy(() => import("./Comp1"));
  const Comp2 = lazy(() => import("./Comp2"));
  return (_props) => (
    <Router>
      <Nav>
        <A activeClass={active} inactiveClass={inactive} end href="/">
          Home
        </A>
        <A activeClass={active} inactiveClass={inactive} end href="/c1">
          Comp1
        </A>
        <A activeClass={active} inactiveClass={inactive} end href="/c2">
          Comp2
        </A>
      </Nav>
      <Routes>
        <Route path="/" component={Home} />
        <Route path="/c1" component={Comp1} />
        <Route path="/c2" component={Comp2} />
      </Routes>
    </Router>
  );
}

const App = app(context);

export default App;
