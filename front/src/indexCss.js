import BauSolidCss from "bau-solidcss";

const { css, styled } = BauSolidCss();

const active = css`
  color: midnightblue;
  font-weight: bold;
  padding: 0.3em;
  border-radius: 5px;
  border: 2px solid;
  background-color: bisque;
  margin-right: 10px;
  text-decoration: none;
`;

const inactive = css`
  color: dodgerblue;
  border-radius: 5px;
  border: 2px solid;
  margin-right: 10px;
  padding: 0.3em;
  text-decoration: none;
`;

const flexed = css`
  display: flex;
`;

const mainNav = css`
  display: flex;
  justify-content: space-between;
  align-content: center;
  align-items: stretch;
  background-color: #282c34;
`;

const img = css`
  display: flex;
  align-items: center;
`;

const Nav = (props) => styled("nav", props)`
  padding: 1em;
  display: flex;
`;

export { active, inactive, flexed, mainNav, img, Nav };
