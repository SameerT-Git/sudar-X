# SudarX

SudarX is a landing page for a Nepali movie and series streaming service — the kind of page you'd land on before signing up. It's built with Next.js, and right now it's a front-end only: the page looks and feels real, but there's no server, no database, and no accounts behind it.

Think of it as the shop window. The shelves are stocked with made-up (but realistic) titles, posters, prices, and FAQs. Clicking around works. Buying a subscription doesn't — yet.

## What you can actually do on the page

- Scroll through a full streaming-service homepage: a big hero film, trending titles, award-winning films, SudarX originals, pricing plans, and FAQs.
- Open a video popup by clicking "Watch Now" or any poster's play button. The demo videos are public sample clips, not real SudarX content.
- Expand and collapse the FAQ answers.
- Open and close the mobile menu, and type in the search box.
- Enjoy the little touches: hover states, a featured-title switcher, the dark cinema-style theme, and a layout that adapts to phones, tablets, and desktops.

## What's not real yet

- **No backend.** Nothing is saved, fetched, or sent anywhere. Every title, price, and answer lives in one file.
- **No login.** The Login, Sign Up, and plan buttons are decoration for now.
- **No other pages.** Links like `/movies`, `/series`, `/search`, and `/my-list` don't lead anywhere.
- **No language switching.** The "नेपाली / EN" button is just a button.
- **No payments.** The plan cards describe the offer; there's no checkout.

That's on purpose. This is the visual and interaction layer — the part you'd build the real product behind later.

## Running it

You'll need Node.js and pnpm installed.

```bash
pnpm install
pnpm dev
```

Then open [http://localhost:3000](http://localhost:3000).

To make a production build:

```bash
pnpm build
pnpm start
```

## How the code is laid out

The project follows the normal Next.js App Router setup, and the folder names mostly tell you what's inside.

```
app/          The page shell: the HTML wrapper, the homepage, and the styles
components/   The visual pieces of the page
data/         All the words, titles, prices, and images in one place
public/       Static files, including the logo
```

### `app/` — the shell

- `layout.tsx` is the frame around every page. It sets up the fonts, page title, dark theme, navbar, and footer.
- `page.tsx` is the homepage itself. It simply stacks the sections in the order you see them on screen.
- `globals.css` is where the look and feel lives: colors, spacing, font sizes, rounded corners. If you want to change the crimson accent or the deep navy background, this is the file.

### `components/` — the pieces

Everything visible on the page is a component, grouped into two folders.

The `home/` folder holds each section of the homepage as its own file:

- `HeroSection.tsx` — the big opening banner with the featured film and its buttons.
- `FeaturedSwitcher.tsx` — the strip of featured titles below the hero.
- `TrendingInNepal.tsx` — the ranked row of currently popular titles.
- `NepalSpotlight.tsx` — a grid of festival and award films.
- `OriginalSeries.tsx` — the SudarX originals shelf.
- `EditorialBanner.tsx` — the "Nepali cinema to the world" message with some stats.
- `ValuePillars.tsx` — the five reasons-to-choose-us cards.
- `SubscriptionPlans.tsx` — the three pricing plans and payment logos.
- `FaqSection.tsx` — the questions and answers accordion.
- `FinalCta.tsx` — the last red "get started" banner.
- `VideoPlayer.tsx` — the shared popup player that every play button opens.

The `layout/` folder holds the frame around the content:

- `Navbar.tsx` — the fixed top bar with the logo, links, search, and auth buttons.
- `NavLinks.tsx` — the Home / Movies / Series / My List links, highlighted when active.
- `SearchField.tsx` — the search pill.
- `LanguageToggle.tsx` — the Nepali/English toggle button.
- `MobileMenu.tsx` — the small-screen dropdown menu.
- `Footer.tsx` — the bottom of the page with link columns, app badges, and social icons.

### `data/` — all the content

`data/landing.ts` is the single source of truth for what appears on the page. The hero film, trending list, spotlight films, originals, banner copy, feature cards, plans, payment methods, and FAQs all come from here.

Want to change a title, rewrite a description, add a plan, or swap a poster? Edit that file and the sections update themselves. You generally shouldn't need to touch the components just to change content.

Poster images are loaded from Google's image host, which is why `next.config.ts` allows that domain. The preview videos are public sample MP4s from around the web.

## How it all fits together

`layout.tsx` provides the frame → `page.tsx` stacks the homepage sections → each section reads its content from `data/landing.ts` → play buttons call the shared `VideoPlayer`, which shows the popup.

There's no fetching and no state beyond small UI things like which FAQ is open or whether the video popup is visible.

## If you're picking this up to keep working on it

- Start with `data/landing.ts` to change content; start with `app/globals.css` to change the look.
- The interactive parts (video popup, FAQ, navbar, search, mobile menu, play buttons) are marked `"use client"` at the top of their files. The rest are plain server components, which is fine — they don't need to run in the browser.
- The logo is at `public/image/logo/screen.png`.
- The next real step would be adding actual pages and a backend, then wiring up authentication, search, and subscriptions.

In short: a polished, self-contained front door for SudarX, ready to be connected to a real product when there is one.
