import { createSignal } from "solid-js";

export default () => {
  const handleClick = () => {
    setCount((c) => c + 1);
  };
  const [count, setCount] = createSignal(0);
  return <button onClick={handleClick}>Count: {count}</button>;
};
