"use client";

import { useState } from "react";
import { Info, Play, Plus, Star, Volume2, VolumeX } from "lucide-react";

import { HERO } from "@/data/landing";
import FeaturedSwitcher from "./FeaturedSwitcher";
import { useVideoPlayer } from "./VideoPlayer";

export default function HeroSection() {
  const { play } = useVideoPlayer();
  const [isMuted, setIsMuted] = useState(false);

  return (
    <section className="relative w-full -mt-20 overflow-hidden bg-surface-container-lowest">
      <div className="relative w-full min-h-[942px] flex items-end overflow-hidden">
        <div
          className="absolute inset-0 bg-cover bg-center bg-no-repeat"
          style={{ backgroundImage: `url("${HERO.backdrop}")` }}
        />
        <div className="absolute inset-0 bg-gradient-to-t from-surface via-surface/60 to-transparent" />
        <div className="absolute inset-0 bg-gradient-to-r from-surface via-surface/70 to-transparent w-full lg:w-3/4" />
        <div className="absolute inset-x-0 top-0 h-32 bg-gradient-to-b from-surface/90 to-transparent" />

        <div className="relative z-10 w-full px-margin-mobile lg:px-margin pt-40 pb-space-xl flex flex-col justify-end max-w-5xl">
          <div className="flex flex-wrap items-center gap-space-xs mb-space-sm">
            <span className="inline-flex items-center gap-1.5 px-space-sm py-0.5 rounded-full bg-primary-container text-on-primary-container font-label-badge text-label-badge uppercase tracking-wider font-bold shadow-[0_0_12px_rgba(220,20,60,0.6)]">
              <span className="w-1.5 h-1.5 rounded-full bg-white animate-ping" />
              {HERO.badges.premiere}
            </span>
            <span className="px-space-sm py-0.5 rounded bg-surface-container-high/80 text-on-surface font-label-badge text-label-badge tracking-wider backdrop-blur-md">
              {HERO.badges.quality}
            </span>
            <span className="px-space-sm py-0.5 rounded bg-secondary-container/90 text-on-secondary-container font-label-badge text-label-badge tracking-wider">
              {HERO.badges.rank}
            </span>
            <span className="px-space-sm py-0.5 rounded bg-surface-container/80 text-primary-fixed font-label-badge text-label-badge tracking-wider">
              {HERO.badges.nepali}
            </span>
          </div>

          <h1 className="font-display-hero text-display-hero-mobile md:text-display-hero tracking-tighter text-white drop-shadow-md mb-space-xs font-extrabold max-w-3xl">
            {HERO.title}
            <span className="block text-headline-lg-mobile md:text-headline-lg font-headline-lg text-primary font-medium tracking-normal mt-1">
              {HERO.subtitle}
            </span>
          </h1>

          <div className="flex flex-wrap items-center gap-x-space-md gap-y-space-xs text-on-surface-variant font-label-md text-label-md mb-space-md">
            <div className="flex items-center gap-1 text-primary">
              <Star aria-hidden="true" size={18} fill="currentColor" />
              <span className="font-bold text-white">{HERO.rating}</span>
              <span className="text-on-surface-variant text-[11px]">
                {HERO.ratingSource}
              </span>
            </div>
            <span className="text-outline-variant">•</span>
            <span>{HERO.duration}</span>
            <span className="text-outline-variant">•</span>
            <span>{HERO.year}</span>
            <span className="text-outline-variant">•</span>
            <span className="px-1.5 py-0.5 rounded bg-surface-variant/70 text-[10px] font-bold text-on-surface">
              {HERO.certificate}
            </span>
            <span className="text-outline-variant">•</span>
            <span className="text-secondary font-medium">{HERO.genres}</span>
          </div>

          <p className="font-body-lg text-body-md md:text-body-lg text-on-surface-variant/90 max-w-2xl line-clamp-3 mb-space-lg leading-relaxed">
            {HERO.synopsis}
          </p>

          <div className="flex flex-wrap items-center gap-space-md">
            <button
              type="button"
              onClick={() =>
                play({
                  title: HERO.title,
                  meta: HERO.genres,
                  poster: HERO.backdrop,
                  video: HERO.video,
                })
              }
              className="group flex items-center justify-center gap-space-sm bg-primary-container text-on-primary-container hover:brightness-110 px-space-xl py-space-sm rounded-full font-label-lg text-label-lg font-bold shadow-[0_0_24px_rgba(220,20,60,0.45)] hover:shadow-[0_0_36px_rgba(220,20,60,0.7)] transition-all transform active:scale-95"
            >
              <Play aria-hidden="true" size={24} fill="currentColor" />
              <span>Watch Now</span>
            </button>

            <button
              type="button"
              className="group flex items-center justify-center gap-space-sm bg-surface-container/60 hover:bg-surface-container text-on-surface px-space-lg py-space-sm rounded-full font-label-lg text-label-lg font-semibold backdrop-blur-xl shadow-md transition-all active:scale-95"
            >
              <Info aria-hidden="true" size={20} />
              <span>More Details</span>
            </button>

            <button
              type="button"
              aria-label="Add to Watchlist"
              className="w-11 h-11 rounded-full bg-surface-container/60 hover:bg-surface-container-high flex items-center justify-center text-on-surface backdrop-blur-md transition-all"
            >
              <Plus aria-hidden="true" size={22} />
            </button>

            <button
              type="button"
              aria-label={isMuted ? "Unmute" : "Mute"}
              aria-pressed={isMuted}
              onClick={() => setIsMuted((muted) => !muted)}
              className="w-11 h-11 rounded-full bg-surface-container/60 hover:bg-surface-container-high flex items-center justify-center text-on-surface backdrop-blur-md transition-all ml-auto"
            >
              {isMuted ? (
                <VolumeX aria-hidden="true" size={20} />
              ) : (
                <Volume2 aria-hidden="true" size={20} />
              )}
            </button>
          </div>
        </div>
      </div>

      <FeaturedSwitcher />
    </section>
  );
}
