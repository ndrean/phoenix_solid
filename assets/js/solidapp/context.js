import { createSignal } from "solid-js";

const [bool, setBool] = createSignal(false),
  [data, setData] = createSignal(0),
  [slide, setSlide] = createSignal(1);

export default {
  bool,
  setBool,
  data,
  setData,
  slide,
  setSlide,
};
