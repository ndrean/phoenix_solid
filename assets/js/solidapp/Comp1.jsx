import { createResource } from "solid-js";
import context from "./context";
import Counter from "./counter";

// async mock
const asyncFunction = (ctx) => (x) =>
  new Promise((resolve, reject) => setTimeout(() => resolve(x * 100), 0)).then(
    ctx.setData
  );

const comp1 = (ctx) => {
  const { bool, setBool, data, slide, setSlide } = ctx;

  return function Comp1() {
    // first async call when component is mounted
    !data() && createResource(10, asyncFunction(ctx));

    return (
      <div>
        <Counter />
        <input
          type="range"
          min="10"
          max="100"
          value={slide()}
          onchange={(e) => {
            setSlide(e.currentTarget.value);
            // dynamic async call
            createResource(e.currentTarget.value, asyncFunction(ctx));
          }}
        />
        <p>{slide()}</p>
        <p> Async dynamic render: {data()}</p>
        <p></p>
        <p>The state "bool" set in the context: {bool() ? "true" : "false"}</p>
        <button onClick={() => setBool((v) => !v)}>Toggle bool</button>
      </div>
    );
  };
};

export default comp1(context);
