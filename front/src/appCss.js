import BauSolidCss from "bau-solidcss";

const { keyframes, css } = BauSolidCss();

const appCl = css`
  text-align: center;
`;

const logoSpin = keyframes`
from {
  transform: rotate(0deg);
}
to {
  transform: rotate(360deg);
}
`;

const phoenixCl = css`
  height: 4vmin;
  pointer-events: none;
`;

const solidCl = css`
  animation: ${logoSpin} infinite 20s linear;
  height: 20vmin;
  pointer-events: none;
`;

const headerCl = css`
  background-color: #282c34;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: calc(10px + 2vmin);
  color: white;
`;

export { phoenixCl, solidCl, headerCl, appCl };
