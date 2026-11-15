"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

type NavItem = {
  label: string;
  href: string;
};

type NavLinksProps = {
  variant: "desktop" | "mobile";
  onNavigate?: () => void;
};

const NAV_ITEMS: readonly NavItem[] = [
  { label: "Home", href: "/" },
  { label: "Movies", href: "/movies" },
  { label: "Series", href: "/series" },
  { label: "My List", href: "/my-list" },
];

const ACTIVE_LINK_CLASSES =
  "transition-colors text-on-primary-container bg-primary-container font-label-lg text-label-lg rounded-full px-space-md py-space-xs shadow-[0_0_12px_rgba(220,20,60,0.4)]";

const INACTIVE_LINK_CLASSES =
  "font-label-lg text-label-lg text-on-surface-variant hover:text-on-surface px-space-md py-space-xs rounded-full transition-colors";

function isLinkActive(pathname: string, href: string) {
  if (href === "/") return pathname === "/";
  return pathname === href || pathname.startsWith(`${href}/`);
}

export default function NavLinks({ variant, onNavigate }: NavLinksProps) {
  const pathname = usePathname();
  const isMobile = variant === "mobile";

  return (
    <nav
      aria-label="Primary"
      className={
        isMobile
          ? "flex flex-col gap-space-xs"
          : "hidden lg:flex items-center gap-space-sm ml-space-md"
      }
    >
      {NAV_ITEMS.map((item) => {
        const isActive = isLinkActive(pathname, item.href);

        return (
          <Link
            key={item.href}
            href={item.href}
            aria-current={isActive ? "page" : undefined}
            onClick={onNavigate}
            className={
              isActive
                ? ACTIVE_LINK_CLASSES
                : `${INACTIVE_LINK_CLASSES}${isMobile ? " w-full text-left" : ""}`
            }
          >
            {item.label}
          </Link>
        );
      })}
    </nav>
  );
}
