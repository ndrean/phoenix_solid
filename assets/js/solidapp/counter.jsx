import { createSignal } from "solid-js";
import socket from "../userSocket.js";
import useChannel from "../useChannel.js";

export default () => {
  const [count, setCount] = createSignal(0);
  const channel = useChannel(socket, "counter:user");

  const handleClick = () => {
    setCount((c) => c + 1);
    channel.push("inc", { count: count() });
  };

  return <button onClick={handleClick}>Count: {count()}</button>;
};
