'use client'

import { Inter } from 'next/font/google'
import './globals.css'
import '@rainbow-me/rainbowkit/styles.css';
import {
  getDefaultWallets,
  RainbowKitProvider,
} from '@rainbow-me/rainbowkit';
import { configureChains, createConfig, WagmiConfig } from 'wagmi';
import {
  mainnet,
  polygon,
  optimism,
  arbitrum,
  base,
  baseGoerli,
  zora,
} from 'wagmi/chains';
import { alchemyProvider } from 'wagmi/providers/alchemy';
import { publicProvider } from 'wagmi/providers/public';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import Link from 'next/link';

const { chains, publicClient } = configureChains(
  [mainnet, polygon, optimism, arbitrum, base, baseGoerli, zora],
  [
    alchemyProvider({ apiKey: process.env.NEXT_PUBLIC_ALCHEMY_ID! }),
    publicProvider()
  ],
  { pollingInterval: 30_000 }
);

const { connectors } = getDefaultWallets({
  appName: 'Base Camp - Roch\'s Final Project',
  projectId: process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID!,
  chains
});

const wagmiConfig = createConfig({
  autoConnect: true,
  connectors,
  publicClient
})

const inter = Inter({ subsets: ['latin'] });

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className + " ms-5 me-5"}>
        <WagmiConfig config={wagmiConfig}>
          <RainbowKitProvider chains={chains}>
            <header className="flex flex-row mt-5 mb-10">
              <div>
                <Link href="/"><h1 className="text-4xl">Leasy 🤝</h1></Link>
              </div>
              <div className="ml-auto"><ConnectButton /></div>
            </header>

            {children}

            <footer className="mb-5 fixed bottom-0 right-5">
              Developed by <a className="underline" target="_blank" href="https://github.com/vince-grondin">Roch</a>
            </footer>
          </RainbowKitProvider>
        </WagmiConfig>
      </body>
    </html>
  )
}
