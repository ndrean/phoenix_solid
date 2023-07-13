import BauSolidCss from "bau-solidcss";

const { css } = BauSolidCss();

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

export { active, inactive, flexed };
