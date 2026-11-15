import Image from "next/image";
import Link from "next/link";
import {
  Cast,
  CirclePlay,
  Globe,
  Megaphone,
  Monitor,
  MonitorPlay,
  Share2,
  Smartphone,
  Tv,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";

type FooterLink = {
  label: string;
  href: string;
};

type FooterColumn = {
  heading: string;
  links: readonly FooterLink[];
};

const FOOTER_COLUMNS: readonly FooterColumn[] = [
  {
    heading: "Explore",
    links: [
      { label: "Home", href: "/" },
      { label: "Movies", href: "/movies" },
      { label: "Series", href: "/series" },
      { label: "Trending", href: "/trending" },
      { label: "Nepalese Classics", href: "/nepalese-classics" },
      { label: "Documentaries", href: "/documentaries" },
    ],
  },
  {
    heading: "Account",
    links: [
      { label: "Login", href: "/login" },
      { label: "Sign Up", href: "/sign-up" },
      { label: "My List", href: "/my-list" },
      { label: "Manage Devices", href: "/manage-devices" },
      { label: "Gift Cards", href: "/gift-cards" },
    ],
  },
  {
    heading: "For Creators",
    links: [
      { label: "Become a Creator", href: "/become-a-creator" },
      { label: "Creator Portal", href: "/creator-portal" },
      { label: "Content Submissions", href: "/content-submissions" },
    ],
  },
  {
    heading: "Support",
    links: [
      { label: "Help Center", href: "/help-center" },
      { label: "Contact Us", href: "/contact-us" },
      { label: "Supported Devices", href: "/supported-devices" },
      { label: "Speed Test", href: "/speed-test" },
      { label: "FAQs", href: "/faqs" },
    ],
  },
  {
    heading: "Legal & Policies",
    links: [
      { label: "Privacy Policy", href: "/privacy-policy" },
      { label: "Terms & Conditions", href: "/terms-and-conditions" },
      { label: "Cookie Preferences", href: "/cookie-preferences" },
      { label: "Content Guidelines", href: "/content-guidelines" },
    ],
  },
];

type Platform = {
  label: string;
  icon: LucideIcon;
};

const PLATFORMS: readonly Platform[] = [
  { label: "Google Play", icon: MonitorPlay },
  { label: "App Store", icon: Smartphone },
  { label: "Android TV", icon: Tv },
  { label: "Apple TV", icon: Monitor },
  { label: "Roku", icon: Cast },
];

type SocialLink = {
  label: string;
  icon: LucideIcon;
  href: string;
};

const SOCIAL_LINKS: readonly SocialLink[] = [
  { label: "Community Channel", icon: Share2, href: "#" },
  { label: "Media Updates", icon: CirclePlay, href: "#" },
  { label: "Notifications Channel", icon: Megaphone, href: "#" },
  { label: "Global Network", icon: Globe, href: "#" },
];

export default function Footer() {
  return (
    <footer className="w-full bg-surface-container-lowest text-on-surface-variant mt-auto">
      <div className="w-full px-margin-mobile lg:px-margin pt-space-xl pb-space-lg">
        {/* Link columns */}
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-space-lg mb-space-xl">
          <div className="col-span-2 md:col-span-3 lg:col-span-1 flex flex-col gap-space-md">
            <div className="flex items-center">
              <Image
                src="/image/logo/screen.png"
                alt="SudarX"
                width={108}
                height={36}
                className="h-8 w-auto object-contain"
              />
            </div>
            <p className="font-body-sm text-body-sm text-on-surface-variant max-w-sm">
              The premier streaming destination for authentic Nepali cinema, and stories.
            </p>
          </div>
          {FOOTER_COLUMNS.map((column) => (
            <div key={column.heading} className="flex flex-col gap-space-sm">
              <h4 className="font-label-lg text-label-lg text-on-surface">
                {column.heading}
              </h4>
              <ul className="flex flex-col gap-space-xs font-body-sm text-body-sm">
                {column.links.map((link) => (
                  <li key={link.href}>
                    <Link
                      href={link.href}
                      className="hover:text-on-surface transition-colors"
                    >
                      {link.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="flex flex-col lg:flex-row items-center justify-between gap-space-md py-space-lg bg-surface-container/30 px-space-md rounded-xl mb-space-lg">
          <div className="flex flex-wrap items-center justify-center gap-space-sm">
            <span className="font-label-md text-label-md text-on-surface-variant mr-space-xs">
              Available on:
            </span>
            {PLATFORMS.map((platform) => (
              <div
                key={platform.label}
                className="flex items-center gap-space-xs bg-surface-container px-space-sm py-space-xs rounded-lg"
              >
                <platform.icon
                  aria-hidden="true"
                  size={18}
                  className="text-on-surface"
                />
                <span className="font-label-badge text-label-badge text-on-surface uppercase">
                  {platform.label}
                </span>
              </div>
            ))}
          </div>

          <div className="flex items-center gap-space-sm">
            {SOCIAL_LINKS.map((social) => (
              <Link
                key={social.label}
                href={social.href}
                aria-label={social.label}
                className="w-9 h-9 rounded-full bg-surface-container flex items-center justify-center text-on-surface-variant hover:text-on-surface hover:bg-surface-container-high transition-colors"
              >
                <social.icon aria-hidden="true" size={20} />
              </Link>
            ))}
          </div>
        </div>

        <div className="text-center font-body-sm text-body-sm text-on-surface-variant/80">
          <p>
            © 2026 SudarX. All Rights Reserved. Crafted with pride for Nepali
            storytellers.
          </p>
        </div>
      </div>
    </footer>
  );
}
