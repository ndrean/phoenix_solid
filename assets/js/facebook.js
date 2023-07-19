export function Facebook(fbutton) {
  (function (d, s, id) {
    var js,
      fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) {
      return;
    }
    js = d.createElement(s);
    js.id = id;
    js.src = "https://connect.facebook.net/en_US/sdk.js";
    fjs.parentNode.insertBefore(js, fjs);
  })(document, "script", "facebook-jssdk");

  window.fbAsyncInit = (function () {
    fbutton.addEventListener("click", () => {
      FB.init({
        appId: `${window.fb_app_id}`,
        cookie: true,
        xfbml: false,
        version: "v17.0",
      });
      FB.getLoginStatus(() => startDialog());
    });
  })();

  function startDialog() {
    FB.login(
      function (response) {
        if (response.status === "connected") {
          graphAPI();
        }
      },
      { scope: "public_profile,email" }
    );
  }

  function graphAPI() {
    FB.api("/me?fields=id,email,name,picture", async function (response) {
      const url = `/fb_login?${build(response)}`;
      return (window.location.href = url);
    });
  }

  function build(response) {
    response.picture = JSON.stringify(response.picture?.data);
    const params = new URLSearchParams(response);
    return params.toString();
  }
}
