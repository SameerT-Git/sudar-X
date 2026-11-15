sudarx/
│
├── public/
│   ├── images/
│   │   ├── logo/
│   │   │   └── sudarx-logo.svg
│   │   ├── hero/
│   │   │   └── shambhala.jpg
│   │   ├── movies/
│   │   ├── series/
│   │   ├── banners/
│   │   └── icons/
│   │
│   └── fonts/
│
├── src/
│   │
│   ├── app/
│   │   ├── (public)/
│   │   │   ├── page.tsx
│   │   │   ├── movies/
│   │   │   │   └── page.tsx
│   │   │   ├── series/
│   │   │   │   └── page.tsx
│   │   │   ├── movie/
│   │   │   │   └── [slug]/
│   │   │   │       └── page.tsx
│   │   │   ├── search/
│   │   │   │   └── page.tsx
│   │   │   ├── my-list/
│   │   │   │   └── page.tsx
│   │   │   └── plans/
│   │   │       └── page.tsx
│   │   │
│   │   ├── (auth)/
│   │   │   ├── login/
│   │   │   │   └── page.tsx
│   │   │   ├── register/
│   │   │   │   └── page.tsx
│   │   │   ├── forgot-password/
│   │   │   │   └── page.tsx
│   │   │   └── reset-password/
│   │   │       └── page.tsx
│   │   │
│   │   ├── creator/
│   │   │   └── (future creator portal)
│   │   │
│   │   ├── admin/
│   │   │   └── (future admin dashboard)
│   │   │
│   │   ├── api/
│   │   │   └── (future backend endpoints)
│   │   │
│   │   ├── layout.tsx
│   │   ├── globals.css
│   │   └── not-found.tsx
│   │
│   ├── components/
│   │   │
│   │   ├── layout/
│   │   │   ├── Navbar.tsx
│   │   │   ├── Footer.tsx
│   │   │   ├── MobileMenu.tsx
│   │   │   └── Container.tsx
│   │   │
│   │   ├── home/
│   │   │   ├── HeroSection.tsx
│   │   │   ├── FeaturedSwitcher.tsx
│   │   │   ├── TrendingSection.tsx
│   │   │   ├── NepalSpotlight.tsx
│   │   │   ├── OriginalSeries.tsx
│   │   │   ├── MovieCategories.tsx
│   │   │   ├── SubscriptionBanner.tsx
│   │   │   ├── FAQSection.tsx
│   │   │   └── FinalCTA.tsx
│   │   │
│   │   ├── movies/
│   │   │   ├── MovieCard.tsx
│   │   │   ├── MovieCarousel.tsx
│   │   │   ├── MovieGrid.tsx
│   │   │   └── MovieMetadata.tsx
│   │   │
│   │   ├── series/
│   │   │   ├── SeriesCard.tsx
│   │   │   └── SeasonCard.tsx
│   │   │
│   │   ├── ui/
│   │   │   ├── Button.tsx
│   │   │   ├── Badge.tsx
│   │   │   ├── SectionHeading.tsx
│   │   │   ├── IconButton.tsx
│   │   │   ├── Skeleton.tsx
│   │   │   └── EmptyState.tsx
│   │   │
│   │   └── providers/
│   │       └── AppProviders.tsx
│   │
│   ├── data/
│   │   ├── movies.ts
│   │   ├── series.ts
│   │   ├── categories.ts
│   │   ├── navigation.ts
│   │   └── faqs.ts
│   │
│   ├── types/
│   │   ├── movie.ts
│   │   ├── series.ts
│   │   ├── user.ts
│   │   └── common.ts
│   │
│   ├── hooks/
│   │   ├── useMobileMenu.ts
│   │   ├── useWatchlist.ts
│   │   └── useCarousel.ts
│   │
│   ├── lib/
│   │   ├── utils.ts
│   │   ├── constants.ts
│   │   └── validations.ts
│   │
│   ├── config/
│   │   ├── site.ts
│   │   └── navigation.ts
│   │
│   └── styles/
│       └── design-tokens.css
│
├── prisma/
│   └── schema.prisma
│
├── tests/
│   └── (future tests)
│
├── .env.example
├── .gitignore
├── next.config.ts
├── package.json
├── tsconfig.json
└── README.md



#	Variable name	HEX color	Color preview
1	surface-tint	#ffb3b3	Pink
2	inverse-on-surface	#27313e	Dark blue-grey
3	surface-variant	#2c3542	Blue-grey
4	surface	#0a1420	Deep navy
5	tertiary-fixed-dim	#c0c6de	Lavender grey
6	primary-fixed	#ffdad9	Light pink
7	tertiary-container	#696f84	Slate grey
8	surface-dim	#0a1420	Deep navy
9	outline	#ac8888	Dusty rose
10	on-secondary-fixed	#001849	Dark navy
11	on-surface-variant	#e6bdbc	Pale rose
12	on-error-container	#ffdad6	Light coral
13	on-primary-fixed-variant	#920022	Dark crimson
14	on-secondary-container	#9eb6ff	Periwinkle
15	tertiary	#c0c6de	Lavender grey
16	inverse-surface	#d9e3f4	Pale blue-grey
17	surface-container-highest	#2c3542	Blue-grey
18	error-container	#93000a	Dark red
19	on-primary	#680015	Deep maroon
20	primary-fixed-dim	#ffb3b3	Pink
21	on-primary-fixed	#40000a	Very dark maroon
22	surface-container-lowest	#050f1a	Midnight navy
23	on-tertiary-fixed-variant	#40465a	Slate blue
24	surface-container	#16202c	Dark blue-grey
25	surface-container-high	#212b37	Dark slate
26	on-secondary-fixed-variant	#12419b	Royal blue
27	inverse-primary	#bf0030	Crimson
28	on-secondary	#002b75	Navy blue
29	outline-variant	#5c3f3f	Dark brown
30	surface-container-low	#121c28	Dark navy-grey
31	on-surface	#d9e3f4	Pale blue-grey
32	on-tertiary-fixed	#141b2d	Midnight blue
33	on-tertiary-container	#f3f3ff	Very light lavender
34	primary-container	#dc143c	Crimson red
35	background	#0a1420	Deep navy
36	secondary-container	#16439e	Royal blue
37	tertiary-fixed	#dce2fa	Pale lavender
38	secondary	#b3c5ff	Light periwinkle
39	on-error	#690005	Dark red
40	error	#ffb4ab	Soft coral
41	on-primary-container	#fff1f0	Off-white pink
42	on-background	#d9e3f4	Pale blue-grey
43	secondary-fixed-dim	#b3c5ff	Light periwinkle
44	on-tertiary	#293042	Dark slate blue
45	surface-bright	#303a47	Slate grey
46	secondary-fixed	#dae1ff	Pale blue
47	primary	#ffb3b3	Pink


