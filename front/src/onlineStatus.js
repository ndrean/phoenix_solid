const onlineStatus = (online) => {
  const setOnline = ({ opacity = 1, bg, src }) => {
    online.style.opacity = opacity;
    online.setAttribute("src", src);
    online.style.backgroundColor = bg;
  };

  if (online) {
    navigator.onLine
      ? setOnline({ src: "/images/online.png", opacity: 0.8, bg: "" })
      : setOnline({ src: "/images/offline.png", bg: "white" });

    window.onoffline = () =>
      setOnline({ src: "/images/offline.png", bg: "white" });

    window.ononline = () =>
      setOnline({ src: "/images/online.png", opacity: 0.8, bg: "" });
  }
};

export default onlineStatus;
