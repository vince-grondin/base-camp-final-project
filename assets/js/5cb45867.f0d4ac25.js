"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[781],{1288:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>c,contentTitle:()=>i,default:()=>l,frontMatter:()=>o,metadata:()=>s,toc:()=>p});var r=n(5893),a=n(1151);const o={},i="Flows & Components",s={id:"Flows/Get bookings",title:"Flows & Components",description:"Add property",source:"@site/docs/3-Flows/7-Get bookings.md",sourceDirName:"3-Flows",slug:"/Flows/Get bookings",permalink:"/base-camp-final-project/Flows/Get bookings",draft:!1,unlisted:!1,tags:[],version:"current",sidebarPosition:7,frontMatter:{},sidebar:"defaultSidebar",previous:{title:"Accept Booking",permalink:"/base-camp-final-project/Flows/Accept Booking"},next:{title:"Quick Start",permalink:"/base-camp-final-project/Quick Start"}},c={},p=[{value:"Add property",id:"add-property",level:2},{value:"Activate property",id:"activate-property",level:2},{value:"List all properties end-to-end flow",id:"list-all-properties-end-to-end-flow",level:2},{value:"Get property details end-to-end flow",id:"get-property-details-end-to-end-flow",level:2}];function d(e){const t={h1:"h1",h2:"h2",mermaid:"mermaid",...(0,a.a)(),...e.components},{Details:n}=t;return n||function(e,t){throw new Error("Expected "+(t?"component":"object")+" `"+e+"` to be defined: you likely forgot to import, pass, or provide it.")}("Details",!0),(0,r.jsxs)(r.Fragment,{children:[(0,r.jsx)(t.h1,{id:"flows--components",children:"Flows & Components"}),"\n",(0,r.jsx)(t.h2,{id:"add-property",children:"Add property"}),"\n",(0,r.jsx)(n,{children:(0,r.jsx)(t.mermaid,{value:"sequenceDiagram\n    actor U as Property Owner\n    participant F as Smart Contract Client\n    participant L as Leasy Smart Contract\n\n    U ->> F: Executes addProperty<br/>in Smart Contract Client\n    activate U\n    activate F\n\n    F ->> L: Calls addProperty\n        activate L\n        L --\x3e> F: Returns true\n        deactivate L\n    F --\x3e> F: Informs Property Owner of success\n\n    deactivate F\n    deactivate U"})}),"\n",(0,r.jsx)(t.h2,{id:"activate-property",children:"Activate property"}),"\n",(0,r.jsx)(n,{children:(0,r.jsx)(t.mermaid,{value:"sequenceDiagram\n    actor U as Property Owner\n    participant F as Smart Contract Client\n    participant L as Leasy Smart Contract\n\n    U ->> F: Executes activateProperty<br/>in Smart Contract Client\n    activate U\n    activate F\n\n    F ->> L: Calls activateProperty\n        alt Property exists, is active and user is owner \u2705\n            activate L\n            L ->> L: Update property status to AVAILABLE, persists required deposit amount for property\n            L --\x3e> F: Returns boolean true\n            deactivate L\n\n            F --\x3e> F: Informs Property Owner of success\n\n        else Property does not exist, is not active or user is not owner \u274c\n            activate L\n            L --\x3e> F: Returns error\n            deactivate L\n\n            F --\x3e> F: Informs Property Owner of failure\n        end\n\n    deactivate F\n    deactivate U"})}),"\n",(0,r.jsx)(t.h2,{id:"list-all-properties-end-to-end-flow",children:"List all properties end-to-end flow"}),"\n",(0,r.jsx)(n,{children:(0,r.jsx)(t.mermaid,{value:"sequenceDiagram\n    actor U as User\n    participant F as Frontend\n    participant L as Leasy Smart Contract\n\n    U ->> F: Navigates to /\n    activate U\n    activate F\n\n    F ->> L: Calls getProperties\n        activate L\n        L --\x3e> F: Returns properties\n        deactivate L\n    F --\x3e> F: Renders grid of property cards\n\n    deactivate F\n    deactivate U"})}),"\n",(0,r.jsx)(t.h2,{id:"get-property-details-end-to-end-flow",children:"Get property details end-to-end flow"}),"\n",(0,r.jsx)(n,{children:(0,r.jsx)(t.mermaid,{value:"sequenceDiagram\n    actor U as User\n    participant F as Frontend\n    participant L as Leasy Smart Contract\n\n    U ->> F: Clicks on property card or<br/>navigates to /property/{propertyID}\n    activate U\n    activate F\n\n    F ->> L: Calls getProperty(uint _propertyID)\n\n        alt Property exists \u2705\n            activate L\n            L --\x3e> F: Returns Property\n            deactivate L\n            \n            F --\x3e> F: Renders property details\n\n            alt Connected user is property owner\n                F ->> L: Calls getBookings(uint _bookingID)\n                activate L\n                L --\x3e> F: Returns bookings, if any\n                deactivate L\n                F --\x3e> F: Renders bookings, if any\n            else Connected user is not property owner\n                F --\x3e> F: No-op\n            end\n\n        else Property does not exist or fails to be fetched \u274c\n            activate L\n            L --\x3e> F: Returns error\n            deactivate L\n\n            F --\x3e> F: Renders error message\n        end\n\n    deactivate F\n    deactivate U"})})]})}function l(e={}){const{wrapper:t}={...(0,a.a)(),...e.components};return t?(0,r.jsx)(t,{...e,children:(0,r.jsx)(d,{...e})}):d(e)}},1151:(e,t,n)=>{n.d(t,{Z:()=>s,a:()=>i});var r=n(7294);const a={},o=r.createContext(a);function i(e){const t=r.useContext(o);return r.useMemo((function(){return"function"==typeof e?e(t):{...t,...e}}),[t,e])}function s(e){let t;return t=e.disableParentContext?"function"==typeof e.components?e.components(a):e.components||a:i(e.components),r.createElement(o.Provider,{value:t},e.children)}}}]);