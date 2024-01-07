"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[882],{9455:(e,n,l)=>{l.r(n),l.d(n,{assets:()=>o,contentTitle:()=>t,default:()=>h,frontMatter:()=>a,metadata:()=>c,toc:()=>i});var s=l(5893),r=l(1151);const a={},t="Smart Contracts",c={id:"Tech Stack/Smart Contracts",title:"Smart Contracts",description:"This codebase uses Foundry, a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.",source:"@site/docs/Tech Stack/Smart Contracts.md",sourceDirName:"Tech Stack",slug:"/Tech Stack/Smart Contracts",permalink:"/Tech Stack/Smart Contracts",draft:!1,unlisted:!1,tags:[],version:"current",frontMatter:{},sidebar:"sidebar",previous:{title:"Frontend",permalink:"/Tech Stack/Frontend"}},o={},i=[{value:"Running locally",id:"running-locally",level:4},{value:"Foundry Popular Commands",id:"foundry-popular-commands",level:4},{value:"Build",id:"build",level:5},{value:"Test",id:"test",level:5},{value:"Format",id:"format",level:5},{value:"Gas Snapshots",id:"gas-snapshots",level:5},{value:"Anvil",id:"anvil",level:5},{value:"Deploy",id:"deploy",level:5},{value:"Cast",id:"cast",level:5},{value:"Help",id:"help",level:5}];function d(e){const n={code:"code",h1:"h1",h4:"h4",h5:"h5",li:"li",ol:"ol",p:"p",pre:"pre",strong:"strong",ul:"ul",...(0,r.a)(),...e.components};return(0,s.jsxs)(s.Fragment,{children:[(0,s.jsx)(n.h1,{id:"smart-contracts",children:"Smart Contracts"}),"\n",(0,s.jsx)(n.p,{children:"This codebase uses Foundry, a blazing fast, portable and modular toolkit for Ethereum application development written in Rust."}),"\n",(0,s.jsx)(n.p,{children:"Foundry consists of:"}),"\n",(0,s.jsxs)(n.ul,{children:["\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Forge"}),": Ethereum testing framework (like Truffle, Hardhat and DappTools)."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Cast"}),": Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Anvil"}),": Local Ethereum node, akin to Ganache, Hardhat Network."]}),"\n",(0,s.jsxs)(n.li,{children:[(0,s.jsx)(n.strong,{children:"Chisel"}),": Fast, utilitarian, and verbose solidity REPL."]}),"\n"]}),"\n",(0,s.jsx)(n.h4,{id:"running-locally",children:"Running locally"}),"\n",(0,s.jsxs)(n.ol,{children:["\n",(0,s.jsx)(n.li,{children:"Start local Ethereum node"}),"\n"]}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-shell",children:"anvil\n"})}),"\n",(0,s.jsxs)(n.ol,{start:"2",children:["\n",(0,s.jsx)(n.li,{children:"Deploy Leasy contract to local Ethereum node"}),"\n"]}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-shell",children:"forge create src/Leasy.sol:Leasy --private-key <private_key_from_anvil_output> --constructor-args <erc-721-token-name> <erc-721-token-symbol>\n"})}),"\n",(0,s.jsx)(n.h4,{id:"foundry-popular-commands",children:"Foundry Popular Commands"}),"\n",(0,s.jsx)(n.h5,{id:"build",children:"Build"}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-shell",children:"$ forge build\n"})}),"\n",(0,s.jsx)(n.h5,{id:"test",children:"Test"}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-shell",children:"$ forge test\n"})}),"\n",(0,s.jsx)(n.h5,{id:"format",children:"Format"}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-shell",children:"$ forge fmt\n"})}),"\n",(0,s.jsx)(n.h5,{id:"gas-snapshots",children:"Gas Snapshots"}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-shell",children:"$ forge snapshot\n"})}),"\n",(0,s.jsx)(n.h5,{id:"anvil",children:"Anvil"}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-shell",children:"$ anvil\n"})}),"\n",(0,s.jsx)(n.h5,{id:"deploy",children:"Deploy"}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-shell",children:"$ forge script script/<contract_name>.s.sol:<contract_script_name> --rpc-url <your_rpc_url> --private-key <your_private_key>\n"})}),"\n",(0,s.jsx)(n.h5,{id:"cast",children:"Cast"}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-shell",children:"$ cast <subcommand>\n"})}),"\n",(0,s.jsx)(n.h5,{id:"help",children:"Help"}),"\n",(0,s.jsx)(n.pre,{children:(0,s.jsx)(n.code,{className:"language-shell",children:"$ forge --help\n$ anvil --help\n$ cast --help\n"})})]})}function h(e={}){const{wrapper:n}={...(0,r.a)(),...e.components};return n?(0,s.jsx)(n,{...e,children:(0,s.jsx)(d,{...e})}):d(e)}},1151:(e,n,l)=>{l.d(n,{Z:()=>c,a:()=>t});var s=l(7294);const r={},a=s.createContext(r);function t(e){const n=s.useContext(a);return s.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function c(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(r):e.components||r:t(e.components),s.createElement(a.Provider,{value:n},e.children)}}}]);