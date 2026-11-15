"use client";

import Image from "next/image";
import { Award, Play } from "lucide-react";

import { NEPAL_SPOTLIGHT } from "@/data/landing";
import { useVideoPlayer } from "./VideoPlayer";

export default function NepalSpotlight() {
  const { play } = useVideoPlayer();

  return (
    <section className="flex flex-col gap-space-md">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-space-xs">
          <Award aria-hidden="true" size={24} className="text-secondary" />
          <h2 className="font-headline-lg-mobile md:text-headline-lg font-headline-lg text-white">
            Nepal Spotlight: Global Festival Winners
          </h2>
        </div>
        <span className="hidden sm:block font-label-md text-label-md text-on-surface-variant">
          Cannes • Venice • Berlinale Selects
        </span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-space-md">
        {NEPAL_SPOTLIGHT.map((item) => (
          <button
            key={item.id}
            type="button"
            onClick={() =>
              play({
                title: item.title,
                meta: item.meta.join(" • "),
                poster: item.poster,
                video: item.video,
              })
            }
            aria-label={`Play ${item.title}`}
            className="group relative rounded-xl overflow-hidden bg-surface-container text-left cursor-pointer transition-all duration-300 hover:shadow-[0_12px_28px_rgba(0,0,0,0.5)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-container"
          >
            <div className="w-full aspect-[16/10] overflow-hidden relative">
              <Image
                src={item.poster}
                alt={`${item.title} still`}
                fill
                sizes="(min-width: 1024px) 25vw, (min-width: 768px) 50vw, 100vw"
                className="object-cover transition-transform duration-500 group-hover:scale-105"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-surface via-surface/40 to-transparent" />

              <div
                className={`absolute top-2.5 left-2.5 px-2 py-0.5 rounded font-label-badge text-label-badge uppercase tracking-wider backdrop-blur-md ${
                  item.awardTone === "primary"
                    ? "bg-primary-container/90 text-white"
                    : "bg-surface-container-highest/90 text-white"
                }`}
              >
                {item.award}
              </div>

              <span className="absolute inset-0 m-auto w-12 h-12 rounded-full bg-primary-container text-white flex items-center justify-center opacity-0 transition-all transform group-hover:opacity-100 group-hover:scale-110 shadow-lg">
                <Play aria-hidden="true" size={28} fill="currentColor" />
              </span>
            </div>

            <div className="p-space-md flex flex-col gap-1">
              <div className="flex items-center justify-between gap-2">
                <h3 className="font-headline-sm text-headline-sm text-white font-semibold group-hover:text-primary transition-colors">
                  {item.title}
                </h3>
                <span className="flex-none font-label-badge text-label-badge text-primary bg-primary-container/20 px-1.5 py-0.5 rounded">
                  {item.score}
                </span>
              </div>
              <p className="font-body-sm text-body-sm text-on-surface-variant line-clamp-2">
                {item.synopsis}
              </p>
              <div className="flex flex-wrap items-center gap-space-sm mt-space-xs text-[11px] text-tertiary">
                {item.meta.map((part, index) => (
                  <span key={part} className="flex items-center gap-space-sm">
                    {index > 0 ? <span>•</span> : null}
                    <span
                      className={
                        index === item.meta.length - 1
                          ? "text-white bg-surface-container-high px-1 rounded"
                          : undefined
                      }
                    >
                      {part}
                    </span>
                  </span>
                ))}
              </div>
            </div>
          </button>
        ))}
      </div>
    </section>
  );
}
