import{o as r}from"./index-be336a2c.js";function s(n,o){if(!n)return null;const e=n.channel(o,{user_token:window.userToken});return e.join().receive("ok",()=>{console.log("Joined successfully")}).receive("error",l=>{console.log("Unable to join",l)}),r(()=>{console.log("closing channel"),e.leave()}),e}export{s as u};