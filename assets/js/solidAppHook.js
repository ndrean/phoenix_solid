import { render } from "solid-js/web";
import { lazy } from "solid-js";

export const SolidAppHook = {
  mounted() {
    const solid = document.getElementById("solid");
    if (!solid) return;

    const App = lazy(() => import("./solidapp/index.jsx"));
    render(() => App(), solid);
  },
};
