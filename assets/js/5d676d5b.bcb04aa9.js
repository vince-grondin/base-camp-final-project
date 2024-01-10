"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[42],{639:(e,n,r)=>{r.r(n),r.d(n,{assets:()=>i,contentTitle:()=>l,default:()=>h,frontMatter:()=>c,metadata:()=>a,toc:()=>o});var t=r(5893),s=r(1151);const c={},l="Quick Start",a={id:"Quick Start",title:"Quick Start",description:"Smart Contracts",source:"@site/docs/4-Quick Start.md",sourceDirName:".",slug:"/Quick Start",permalink:"/base-camp-final-project/Quick Start",draft:!1,unlisted:!1,tags:[],version:"current",sidebarPosition:4,frontMatter:{},sidebar:"defaultSidebar",previous:{title:"Flows",permalink:"/base-camp-final-project/Flows"},next:{title:"Frontend",permalink:"/base-camp-final-project/Detailed Guides/Frontend"}},i={},o=[{value:"Smart Contracts",id:"smart-contracts",level:2},{value:"Frontend",id:"frontend",level:2}];function d(e){const n={a:"a",code:"code",h1:"h1",h2:"h2",li:"li",ol:"ol",p:"p",pre:"pre",...(0,s.a)(),...e.components};return(0,t.jsxs)(t.Fragment,{children:[(0,t.jsx)(n.h1,{id:"quick-start",children:"Quick Start"}),"\n",(0,t.jsx)(n.h2,{id:"smart-contracts",children:"Smart Contracts"}),"\n",(0,t.jsxs)(n.ol,{children:["\n",(0,t.jsx)(n.li,{children:"Start local Ethereum node"}),"\n"]}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-shell",children:"cd contracts; anvil\n"})}),"\n",(0,t.jsxs)(n.ol,{start:"2",children:["\n",(0,t.jsx)(n.li,{children:"Deploy Leasy contract to local Ethereum node"}),"\n"]}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-shell",children:"forge create src/Leasy.sol:Leasy --private-key <private_key_from_anvil_output> --constructor-args <erc-721-token-name> <erc-721-token-symbol>\n"})}),"\n",(0,t.jsxs)(n.ol,{start:"3",children:["\n",(0,t.jsxs)(n.li,{children:["\n",(0,t.jsx)(n.p,{children:"Copy address of deployed contract to clipboard"}),"\n"]}),"\n",(0,t.jsxs)(n.li,{children:["\n",(0,t.jsx)(n.p,{children:"Build"}),"\n"]}),"\n"]}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-shell",children:"$ forge build\n"})}),"\n",(0,t.jsxs)(n.ol,{start:"5",children:["\n",(0,t.jsxs)(n.li,{children:["\n",(0,t.jsx)(n.p,{children:"Navigate to Remix IDE"}),"\n"]}),"\n",(0,t.jsxs)(n.li,{children:["\n",(0,t.jsxs)(n.p,{children:["Click on ",(0,t.jsx)(n.code,{children:"Deploy & run transactions"}),", select ",(0,t.jsx)(n.code,{children:"Dev - Foundry Provider"}),", enter contract address from output of step 3.\nin ",(0,t.jsx)(n.code,{children:"At Address"})," field and interact with contract"]}),"\n"]}),"\n"]}),"\n",(0,t.jsx)(n.h2,{id:"frontend",children:"Frontend"}),"\n",(0,t.jsxs)(n.ol,{children:["\n",(0,t.jsx)(n.li,{children:"Start Frontend"}),"\n"]}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-shell",children:"cd frontend; npm i; npm run dev\n"})}),"\n",(0,t.jsxs)(n.ol,{start:"2",children:["\n",(0,t.jsxs)(n.li,{children:["Create ",(0,t.jsx)(n.code,{children:".env.local"})," file with properties:"]}),"\n"]}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{children:"NEXT_PUBLIC_ALCHEMY_ID=<your alchemy ID>\nNEXT_PUBLIC_LEASY_CONTRACT_ADDRESS=<address of contract from step 3.>\nNEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=<your wallet connect project ID>\n"})}),"\n",(0,t.jsxs)(n.ol,{start:"2",children:["\n",(0,t.jsxs)(n.li,{children:["Navigate to ",(0,t.jsx)(n.a,{href:"http://localhost:3000",children:"http://localhost:3000"})]}),"\n"]})]})}function h(e={}){const{wrapper:n}={...(0,s.a)(),...e.components};return n?(0,t.jsx)(n,{...e,children:(0,t.jsx)(d,{...e})}):d(e)}}}]);