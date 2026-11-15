"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Menu, User, X } from "lucide-react";

import LanguageToggle from "./LanguageToggle";
import MobileMenu from "./MobileMenu";
import NavLinks from "./NavLinks";
import SearchField from "./SearchField";

const MOBILE_MENU_ID = "mobile-navigation";

export default function Navbar() {
  const pathname = usePathname();
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [previousPathname, setPreviousPathname] = useState(pathname);

  if (previousPathname !== pathname) {
    setPreviousPathname(pathname);
    setIsMenuOpen(false);
  }

  useEffect(() => {
    if (!isMenuOpen) return;

    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") setIsMenuOpen(false);
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isMenuOpen]);

  const closeMenu = () => setIsMenuOpen(false);
  const toggleMenu = () => setIsMenuOpen((isOpen) => !isOpen);

  return (
    <header className="fixed top-0 left-0 right-0 z-50 bg-surface/90 backdrop-blur-md shadow-[0_1px_8px_rgba(0,0,0,0.4)]">
      <div className="h-20 w-full px-margin-mobile lg:px-margin flex items-center justify-between gap-space-md">
        <div className="flex items-center gap-space-lg">
          <Link href="/" className="flex items-center">
            <Image
              src="/image/logo/screen.png"
              alt="SudarX"
              width={108}
              height={36}
              preload={true}
              className="h-8 w-auto object-contain"
            />
          </Link>
          <NavLinks variant="desktop" />
        </div>

        <div className="flex items-center gap-space-md">
          <SearchField className="hidden sm:flex w-56 lg:w-72" />
          <LanguageToggle className="hidden md:flex" />

          <Link
            href="/login"
            className="hidden sm:inline-flex font-label-lg text-label-lg text-on-surface hover:text-primary transition-colors px-space-sm py-space-xs"
          >
            Login
          </Link>
          <Link
            href="/sign-up"
            className="font-label-lg text-label-lg bg-primary-container text-on-primary-container px-space-lg py-space-sm rounded-full shadow-[0_4px_16px_rgba(220,20,60,0.35)] hover:shadow-[0_6px_24px_rgba(220,20,60,0.6)] hover:brightness-110 transition-all font-semibold"
          >
            Sign Up
          </Link>

          <div className="flex items-center gap-space-sm ml-space-xs">
            <Link
              href="/login"
              aria-label="Account"
              className="w-8 h-8 rounded-full flex items-center justify-center bg-surface-container text-on-surface-variant hover:text-on-surface hover:bg-surface-container-high transition-colors"
            >
              <User aria-hidden="true" size={20} />
            </Link>

            <button
              type="button"
              aria-label="Toggle navigation menu"
              aria-expanded={isMenuOpen}
              aria-controls={MOBILE_MENU_ID}
              onClick={toggleMenu}
              className="lg:hidden flex items-center justify-center w-10 h-10 rounded-lg text-on-surface hover:bg-surface-container transition-colors"
            >
              {isMenuOpen ? (
                <X aria-hidden="true" size={24} />
              ) : (
                <Menu aria-hidden="true" size={24} />
              )}
            </button>
          </div>
        </div>
      </div>

      {isMenuOpen && <MobileMenu id={MOBILE_MENU_ID} onClose={closeMenu} />}
    </header>
  );
}
