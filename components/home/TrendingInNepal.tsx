"use client";

import Image from "next/image";
import Link from "next/link";
import { ChevronRight, Flame, Play } from "lucide-react";

import { TRENDING_IN_NEPAL } from "@/data/landing";
import type { BadgeTone } from "@/data/landing";
import { useVideoPlayer } from "./VideoPlayer";

const BADGE_TONES: Record<BadgeTone, string> = {
  primary: "bg-primary-container text-white",
  muted: "bg-surface-container-high/90 text-white",
  error: "bg-error-container text-white",
};

export default function TrendingInNepal() {
  const { play } = useVideoPlayer();

  return (
    <section className="flex flex-col gap-space-md">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-space-xs">
          <Flame
            aria-hidden="true"
            size={24}
            className="text-primary-container"
          />
          <h2 className="font-headline-lg-mobile md:text-headline-lg font-headline-lg text-white">
            Trending in Nepal
          </h2>
        </div>
        <Link
          href="/trending"
          className="flex items-center gap-1 font-label-md text-label-md text-primary hover:text-white transition-colors"
        >
          <span>Explore All 20 Titles</span>
          <ChevronRight aria-hidden="true" size={16} />
        </Link>
      </div>

      <div className="flex gap-space-md overflow-x-auto pb-space-sm pt-space-xs snap-x snap-mandatory">
        {TRENDING_IN_NEPAL.map((item) => (
          <button
            key={item.id}
            type="button"
            onClick={() =>
              play({
                title: item.title,
                meta: item.meta,
                poster: item.poster,
                video: item.video,
              })
            }
            aria-label={`Play ${item.title}`}
            className="group snap-start flex-none w-52 md:w-60 relative text-left rounded-xl transition-transform duration-300 hover:scale-[1.04] hover:z-20 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-container focus-visible:ring-offset-2 focus-visible:ring-offset-background"
          >
            <div className="relative w-full aspect-[2/3] rounded-xl overflow-hidden bg-surface-container shadow-lg">
              <Image
                src={item.poster}
                alt={`${item.title} poster`}
                fill
                sizes="(min-width: 768px) 15rem, 13rem"
                className="object-cover transition duration-300 group-hover:brightness-110"
              />

              <div className="absolute inset-0 bg-gradient-to-t from-surface via-transparent to-transparent opacity-90" />

              <span className="absolute -left-2 bottom-6 font-display-hero text-6xl md:text-8xl font-black text-white/20 select-none pointer-events-none transition-colors group-hover:text-primary-container/40">
                {item.rank}
              </span>

              {item.badge ? (
                <span
                  className={`absolute top-2 left-2 px-2 py-0.5 rounded font-label-badge text-label-badge font-bold ${BADGE_TONES[item.badge.tone]}`}
                >
                  {item.badge.label}
                </span>
              ) : null}

              <span className="absolute inset-0 m-auto w-14 h-14 rounded-full bg-primary-container/90 text-white flex items-center justify-center opacity-0 transition-opacity group-hover:opacity-100 shadow-[0_0_24px_rgba(220,20,60,0.6)]">
                <Play aria-hidden="true" size={30} fill="currentColor" />
              </span>

              <div className="absolute bottom-2 left-3 right-3">
                <span className="block truncate font-headline-sm text-headline-sm font-bold text-white">
                  {item.title}
                </span>
              </div>
            </div>
          </button>
        ))}
      </div>
    </section>
  );
}
