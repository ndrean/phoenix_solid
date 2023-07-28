import { createResource } from "solid-js";
import BauSolidCss from "bau-solidcss";
import context from "./context";
import Chart from "./Chart";
// import Counter from "./counter";
const { css } = BauSolidCss();

const chartCss = css`
  display: flex;
  justify-content: center;
`;
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
        <div>
          <input
            type="range"
            min="1"
            max="10"
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
          <p>
            The state "bool" set in the context: {bool() ? "true" : "false"}
          </p>
          <button onClick={() => setBool((v) => !v)}>Toggle bool</button>
        </div>
        <div class={chartCss}>
          <Chart multi={slide()} />
        </div>
      </div>
    );
  };
};

export default comp1(context);
