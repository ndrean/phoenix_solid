import BauSolidCss from "bau-solidcss";

const { css } = BauSolidCss();

export default (tab) => {
  const welcome = document.getElementById("welcome");
  const spahook = document.getElementById("spahook");

  if (welcome && spahook) {
    console.log(welcome.classList);
  }
};
