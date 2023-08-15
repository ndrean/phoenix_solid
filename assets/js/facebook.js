export function Facebook(fbutton) {
  // (function (d, s, id) {
  //   var js,
  //     fjs = d.getElementsByTagName(s)[0];
  //   if (d.getElementById(id)) {
  //     return;
  //   }
  //   js = d.createElement(s);
  //   js.id = id;
  //   js.src = "https://connect.facebook.net/en_US/sdk.js";
  //   fjs.parentNode.insertBefore(js, fjs);
  // })(document, "script", "facebook-jssdk");

  fbutton.addEventListener("click", () => {
    FB.init({
      appId: window.fbAppId,
      cookie: true,
      xfbml: false,
      version: "v17.0",
    });
    FB.getLoginStatus(({ status }) => {
      status === "connected"
        ? graphAPI()
        : FB.login(
            function ({ status }) {
              status === "connected" && graphAPI();
            },
            { scope: "public_profile,email" }
          );
    });
  });

  function graphAPI() {
    FB.api("/me?fields=id,email,name", async function (response) {
      const params = new URLSearchParams(response).toString();
      return (window.location.href = `/fb_login?${params}`);
    });
  }
}
