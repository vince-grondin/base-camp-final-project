import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Leasy Documentation',
  tagline: 'Leasy Documentation',
  favicon: 'img/favicon.ico',

  url: 'https://github.com',
  baseUrl: '/base-camp-final-project/',
  organizationName: 'vince-grondin',
  projectName: 'base-camp-final-project',
  trailingSlash: false,
  deploymentBranch: 'gh-pages',

  onBrokenLinks: 'ignore',
  onBrokenMarkdownLinks: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          routeBasePath: '/'
        },
        blog: false
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    navbar: {
      title: 'Leasy Documentation',
      logo: {
        alt: 'Leasy Documentation Logo',
        src: 'img/logo.png',
      },
      items: [
        {
          href: 'https://github.com/vince-grondin/base-camp-final-project',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Docs',
              to: '/docs/intro',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/vince-grondin/base-camp-final-project',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Leasy Documentation, Inc. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,

  markdown: {
    mermaid: true,
  },
  themes: ['@docusaurus/theme-mermaid'],
};

export default config;
