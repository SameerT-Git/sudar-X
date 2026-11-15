"use client";

import Image from "next/image";
import Link from "next/link";
import { Play, Tv } from "lucide-react";

import { ORIGINAL_SERIES } from "@/data/landing";
import { useVideoPlayer } from "./VideoPlayer";

export default function OriginalSeries() {
  const { play } = useVideoPlayer();

  return (
    <section className="flex flex-col gap-space-md">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-space-xs">
          <Tv aria-hidden="true" size={24} className="text-primary" />
          <h2 className="font-headline-lg-mobile md:text-headline-lg font-headline-lg text-white">
            SudarX Original Series
          </h2>
          <span className="ml-2 px-2 py-0.5 rounded-full bg-secondary-container/80 text-on-secondary-container font-label-badge text-label-badge uppercase">
            Binge In 4K
          </span>
        </div>
        <Link
          href="/series"
          className="font-label-md text-label-md text-on-surface-variant hover:text-white transition-colors"
        >
          View All Series
        </Link>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-space-md">
        {ORIGINAL_SERIES.map((item) => (
          <button
            key={item.id}
            type="button"
            onClick={() =>
              play({
                title: item.title,
                meta: item.episodes,
                poster: item.poster,
                video: item.video,
              })
            }
            aria-label={`Play ${item.title}`}
            className="group relative rounded-xl overflow-hidden bg-surface-container text-left cursor-pointer transition-all duration-300 hover:scale-105 hover:z-20 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-container"
          >
            <div className="w-full aspect-[2/3] relative">
              <Image
                src={item.poster}
                alt={`${item.title} cover art`}
                fill
                sizes="(min-width: 1024px) 16vw, (min-width: 640px) 33vw, 50vw"
                className="object-cover transition duration-300 group-hover:brightness-110"
              />

              <div className="absolute inset-0 bg-gradient-to-t from-surface via-transparent to-transparent opacity-80" />

              <span
                className={`absolute top-2 left-2 px-1.5 py-0.5 rounded font-label-badge text-label-badge ${item.tagClass}`}
              >
                {item.tag}
              </span>

              <span className="absolute inset-0 m-auto w-12 h-12 rounded-full bg-primary-container/90 text-white flex items-center justify-center opacity-0 transition-opacity group-hover:opacity-100 shadow-[0_0_24px_rgba(220,20,60,0.6)]">
                <Play aria-hidden="true" size={24} fill="currentColor" />
              </span>

              <div className="absolute bottom-2 left-2 right-2">
                <p className="font-headline-sm text-headline-sm text-white truncate font-bold">
                  {item.title}
                </p>
                <p className="font-body-sm text-body-sm text-secondary">
                  {item.episodes}
                </p>
              </div>
            </div>
          </button>
        ))}
      </div>
    </section>
  );
}
