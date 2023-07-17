import { createSignal } from "solid-js";
import BauSolidCss from "bau-solidcss";

const { css, styled, keyframes } = BauSolidCss();

const [bool, setBool] = createSignal(false),
  [data, setData] = createSignal(0),
  [slide, setSlide] = createSignal(10);

export default {
  bool,
  setBool,
  data,
  setData,
  slide,
  setSlide,
  css,
  styled,
  keyframes,
};
