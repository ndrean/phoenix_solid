(function(){const s=document.createElement("link").relList;if(s&&s.supports&&s.supports("modulepreload"))return;for(const i of document.querySelectorAll('link[rel="modulepreload"]'))n(i);new MutationObserver(i=>{for(const l of i)if(l.type==="childList")for(const r of l.addedNodes)r.tagName==="LINK"&&r.rel==="modulepreload"&&n(r)}).observe(document,{childList:!0,subtree:!0});function t(i){const l={};return i.integrity&&(l.integrity=i.integrity),i.referrerPolicy&&(l.referrerPolicy=i.referrerPolicy),i.crossOrigin==="use-credentials"?l.credentials="include":i.crossOrigin==="anonymous"?l.credentials="omit":l.credentials="same-origin",l}function n(i){if(i.ep)return;i.ep=!0;const l=t(i);fetch(i.href,l)}})();const K=(e,s)=>e===s,B={equals:K};let Q=R;const b=1,v=2,F={owned:null,cleanups:null,context:null,owner:null};var d=null;let T=null,f=null,h=null,g=null,x=0;function W(e,s){const t=f,n=d,i=e.length===0,l=i?F:{owned:null,cleanups:null,context:null,owner:s===void 0?n:s},r=i?e:()=>e(()=>C(()=>E(l)));d=l,f=null;try{return w(r,!0)}finally{f=t,d=n}}function X(e,s){s=s?Object.assign({},B,s):B;const t={value:e,observers:null,observerSlots:null,comparator:s.equals||void 0},n=i=>(typeof i=="function"&&(i=i(t.value)),I(t,i));return[Y.bind(t),n]}function A(e,s,t){const n=z(e,s,!1,b);L(n)}function C(e){if(f===null)return e();const s=f;f=null;try{return e()}finally{f=s}}function Y(){if(this.sources&&this.state)if(this.state===b)L(this);else{const e=h;h=null,w(()=>S(this),!1),h=e}if(f){const e=this.observers?this.observers.length:0;f.sources?(f.sources.push(this),f.sourceSlots.push(e)):(f.sources=[this],f.sourceSlots=[e]),this.observers?(this.observers.push(f),this.observerSlots.push(f.sources.length-1)):(this.observers=[f],this.observerSlots=[f.sources.length-1])}return this.value}function I(e,s,t){let n=e.value;return(!e.comparator||!e.comparator(n,s))&&(e.value=s,e.observers&&e.observers.length&&w(()=>{for(let i=0;i<e.observers.length;i+=1){const l=e.observers[i],r=T&&T.running;r&&T.disposed.has(l),(r?!l.tState:!l.state)&&(l.pure?h.push(l):g.push(l),l.observers&&G(l)),r||(l.state=b)}if(h.length>1e6)throw h=[],new Error},!1)),s}function L(e){if(!e.fn)return;E(e);const s=d,t=f,n=x;f=d=e,Z(e,e.value,n),f=t,d=s}function Z(e,s,t){let n;try{n=e.fn(s)}catch(i){return e.pure&&(e.state=b,e.owned&&e.owned.forEach(E),e.owned=null),e.updatedAt=t+1,H(i)}(!e.updatedAt||e.updatedAt<=t)&&(e.updatedAt!=null&&"observers"in e?I(e,n):e.value=n,e.updatedAt=t)}function z(e,s,t,n=b,i){const l={fn:e,state:n,updatedAt:null,owned:null,sources:null,sourceSlots:null,cleanups:null,value:s,owner:d,context:null,pure:t};return d===null||d!==F&&(d.owned?d.owned.push(l):d.owned=[l]),l}function M(e){if(e.state===0)return;if(e.state===v)return S(e);if(e.suspense&&C(e.suspense.inFallback))return e.suspense.effects.push(e);const s=[e];for(;(e=e.owner)&&(!e.updatedAt||e.updatedAt<x);)e.state&&s.push(e);for(let t=s.length-1;t>=0;t--)if(e=s[t],e.state===b)L(e);else if(e.state===v){const n=h;h=null,w(()=>S(e,s[0]),!1),h=n}}function w(e,s){if(h)return e();let t=!1;s||(h=[]),g?t=!0:g=[],x++;try{const n=e();return ee(t),n}catch(n){t||(g=null),h=null,H(n)}}function ee(e){if(h&&(R(h),h=null),e)return;const s=g;g=null,s.length&&w(()=>Q(s),!1)}function R(e){for(let s=0;s<e.length;s++)M(e[s])}function S(e,s){e.state=0;for(let t=0;t<e.sources.length;t+=1){const n=e.sources[t];if(n.sources){const i=n.state;i===b?n!==s&&(!n.updatedAt||n.updatedAt<x)&&M(n):i===v&&S(n,s)}}}function G(e){for(let s=0;s<e.observers.length;s+=1){const t=e.observers[s];t.state||(t.state=v,t.pure?h.push(t):g.push(t),t.observers&&G(t))}}function E(e){let s;if(e.sources)for(;e.sources.length;){const t=e.sources.pop(),n=e.sourceSlots.pop(),i=t.observers;if(i&&i.length){const l=i.pop(),r=t.observerSlots.pop();n<i.length&&(l.sourceSlots[r]=n,i[n]=l,t.observerSlots[n]=r)}}if(e.owned){for(s=e.owned.length-1;s>=0;s--)E(e.owned[s]);e.owned=null}if(e.cleanups){for(s=e.cleanups.length-1;s>=0;s--)e.cleanups[s]();e.cleanups=null}e.state=0,e.context=null}function H(e){throw e}function V(e,s){return C(()=>e(s||{}))}function te(e,s,t){let n=t.length,i=s.length,l=n,r=0,o=0,u=s[i-1].nextSibling,a=null;for(;r<i||o<l;){if(s[r]===t[o]){r++,o++;continue}for(;s[i-1]===t[l-1];)i--,l--;if(i===r){const c=l<n?o?t[o-1].nextSibling:t[l-o]:u;for(;o<l;)e.insertBefore(t[o++],c)}else if(l===o)for(;r<i;)(!a||!a.has(s[r]))&&s[r].remove(),r++;else if(s[r]===t[l-1]&&t[o]===s[i-1]){const c=s[--i].nextSibling;e.insertBefore(t[o++],s[r++].nextSibling),e.insertBefore(t[--l],c),s[i]=t[l]}else{if(!a){a=new Map;let p=o;for(;p<l;)a.set(t[p],p++)}const c=a.get(s[r]);if(c!=null)if(o<c&&c<l){let p=r,N=1,P;for(;++p<i&&p<l&&!((P=a.get(s[p]))==null||P!==c+N);)N++;if(N>c-o){const J=s[r];for(;o<c;)e.insertBefore(t[o++],J)}else e.replaceChild(t[o++],s[r++])}else r++;else s[r++].remove()}}}const D="_$DX_DELEGATE";function se(e,s,t,n={}){let i;return W(l=>{i=l,s===document?e():O(s,e(),s.firstChild?null:void 0,t)},n.owner),()=>{i(),s.textContent=""}}function k(e,s,t){let n;const i=()=>{const r=document.createElement("template");return r.innerHTML=e,t?r.content.firstChild.firstChild:r.content.firstChild},l=s?()=>C(()=>document.importNode(n||(n=i()),!0)):()=>(n||(n=i())).cloneNode(!0);return l.cloneNode=l,l}function ne(e,s=window.document){const t=s[D]||(s[D]=new Set);for(let n=0,i=e.length;n<i;n++){const l=e[n];t.has(l)||(t.add(l),s.addEventListener(l,ie))}}function U(e,s,t){t==null?e.removeAttribute(s):e.setAttribute(s,t)}function _(e,s){s==null?e.removeAttribute("class"):e.className=s}function O(e,s,t,n){if(t!==void 0&&!n&&(n=[]),typeof s!="function")return $(e,s,n,t);A(i=>$(e,s(),i,t),n)}function ie(e){const s=`$$${e.type}`;let t=e.composedPath&&e.composedPath()[0]||e.target;for(e.target!==t&&Object.defineProperty(e,"target",{configurable:!0,value:t}),Object.defineProperty(e,"currentTarget",{configurable:!0,get(){return t||document}});t;){const n=t[s];if(n&&!t.disabled){const i=t[`${s}Data`];if(i!==void 0?n.call(t,i,e):n.call(t,e),e.cancelBubble)return}t=t._$host||t.parentNode||t.host}}function $(e,s,t,n,i){for(;typeof t=="function";)t=t();if(s===t)return t;const l=typeof s,r=n!==void 0;if(e=r&&t[0]&&t[0].parentNode||e,l==="string"||l==="number")if(l==="number"&&(s=s.toString()),r){let o=t[0];o&&o.nodeType===3?o.data=s:o=document.createTextNode(s),t=y(e,t,n,o)}else t!==""&&typeof t=="string"?t=e.firstChild.data=s:t=e.textContent=s;else if(s==null||l==="boolean")t=y(e,t,n);else{if(l==="function")return A(()=>{let o=s();for(;typeof o=="function";)o=o();t=$(e,o,t,n)}),()=>t;if(Array.isArray(s)){const o=[],u=t&&Array.isArray(t);if(j(o,s,t,i))return A(()=>t=$(e,o,t,n,!0)),()=>t;if(o.length===0){if(t=y(e,t,n),r)return t}else u?t.length===0?q(e,o,n):te(e,t,o):(t&&y(e),q(e,o));t=o}else if(s.nodeType){if(Array.isArray(t)){if(r)return t=y(e,t,n,s);y(e,t,null,s)}else t==null||t===""||!e.firstChild?e.appendChild(s):e.replaceChild(s,e.firstChild);t=s}else console.warn("Unrecognized value. Skipped inserting",s)}return t}function j(e,s,t,n){let i=!1;for(let l=0,r=s.length;l<r;l++){let o=s[l],u=t&&t[l],a;if(!(o==null||o===!0||o===!1))if((a=typeof o)=="object"&&o.nodeType)e.push(o);else if(Array.isArray(o))i=j(e,o,u)||i;else if(a==="function")if(n){for(;typeof o=="function";)o=o();i=j(e,Array.isArray(o)?o:[o],Array.isArray(u)?u:[u])||i}else e.push(o),i=!0;else{const c=String(o);u&&u.nodeType===3&&u.data===c?e.push(u):e.push(document.createTextNode(c))}}return i}function q(e,s,t=null){for(let n=0,i=s.length;n<i;n++)e.insertBefore(s[n],t)}function y(e,s,t,n){if(t===void 0)return e.textContent="";const i=n||document.createTextNode("");if(s.length){let l=!1;for(let r=s.length-1;r>=0;r--){const o=s[r];if(i!==o){const u=o.parentNode===e;!l&&!r?u?e.replaceChild(i,o):e.insertBefore(i,t):u&&o.remove()}else l=!0}}else e.insertBefore(i,t);return[i]}const le="/spa/assets/logo-123b04bc.svg",oe="/spa/assets/phoenix-150a2de5.svg",re="_App_1jhgk_1",fe="_phoenix_1jhgk_14",ue="_solid_1jhgk_19",ce="_header_1jhgk_25",m={App:re,phoenix:fe,solid:ue,"logo-spin":"_logo-spin_1jhgk_1",header:ce},he=k("<button>Count: "),ae=()=>{const e=()=>{t(n=>n+1)},[s,t]=X(0);return(()=>{const n=he();return n.firstChild,n.$$click=e,O(n,s,null),n})()};ne(["click"]);const de=k('<div><header><a href="https://github.com/solidjs/solid" target="_blank"><img alt="solid"></a><a href="https://github.com/solidjs/solid" target="_blank"><img alt="phoenix"></a><h1>Phoenix renders SolidJS</h1><br>');function pe(){return(()=>{const e=de(),s=e.firstChild,t=s.firstChild,n=t.firstChild,i=t.nextSibling,l=i.firstChild;return i.nextSibling.nextSibling,U(n,"src",le),U(l,"src",oe),O(s,V(ae,{}),null),A(o=>{const u=m.App,a=m.header,c=m.solid,p=m.phoenix;return u!==o._v$&&_(e,o._v$=u),a!==o._v$2&&_(s,o._v$2=a),c!==o._v$3&&_(n,o._v$3=c),p!==o._v$4&&_(l,o._v$4=p),o},{_v$:void 0,_v$2:void 0,_v$3:void 0,_v$4:void 0}),e})()}const ge=document.getElementById("root");se(()=>V(pe,{}),ge);