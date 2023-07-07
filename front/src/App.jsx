import logo from "./assets/logo.svg";
import phoenix from "./assets/phoenix.svg";
import styles from "./App.module.css";
import Counter from "./counter";

function App() {
  return (
    <div class={styles.App}>
      <header class={styles.header}>
        <a href="https://github.com/solidjs/solid" target="_blank">
          <img src={logo} class={styles.solid} alt="solid" />
        </a>
        <a href="https://github.com/solidjs/solid" target="_blank">
          <img src={phoenix} class={styles.phoenix} alt="phoenix" />
        </a>

        <h1>Phoenix renders SolidJS</h1>
        <br />
        <Counter />
      </header>
    </div>
  );
}

export default App;
