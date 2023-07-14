import onlineUrl from "/images/online.png";
import offlineUrl from "/images/offline.png";

export const onlineListener = (onlineStatus) => {
  const setOnline = ({ opacity = 1, bg, src }) => {
    onlineStatus.style.opacity = opacity;
    onlineStatus.setAttribute("src", src);
    onlineStatus.style.backgroundColor = bg;
  };
  window.onload = () => {
    navigator.onLine
      ? setOnline({ src: onlineUrl, opacity: 0.8, bg: "" })
      : setOnline({ src: offlineUrl, bg: "white" });
  };

  window.onoffline = () => setOnline({ src: offlineUrl, bg: "white" });
  window.ononline = () => setOnline({ src: onlineUrl, opacity: 0.8, bg: "" });
};
