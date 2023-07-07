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

  window.fbAsyncInit = function () {
    FB.init({
      appId: `${window.app_id}`,
      cookie: true,
      xfbml: false,
      version: "v15.0",
    });
    fbutton.addEventListener("click", () => {
      FB.getLoginStatus(function (response) {
        statusChangeCallback(response);
      });
    });
  };

  function statusChangeCallback(response) {
    if (response.status === "connected") {
      graphAPI();
    } else {
      startDialog();
    }
  }

  function graphAPI() {
    FB.api("/me?fields=id,email,name,picture", async function (response) {
      const url = `/auth/fbk/sdk?${build(response)}`;
      return (window.location.href = url);
    });
  }

  function build(response) {
    response.picture = JSON.stringify(response.picture.data);
    const params = new URLSearchParams(response);
    return params.toString();
  }

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
}
