"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useRef,
  useState,
} from "react";
import type { ReactNode } from "react";
import { X } from "lucide-react";

export type VideoSource = {
  title: string;
  meta?: string;
  poster: string;
  video: string;
};

type VideoPlayerContextValue = {
  /** Open the player modal and start the given clip. */
  play: (source: VideoSource) => void;
};

const VideoPlayerContext = createContext<VideoPlayerContextValue | null>(null);

export function useVideoPlayer() {
  const context = useContext(VideoPlayerContext);
  if (!context) {
    throw new Error("useVideoPlayer must be used within <VideoPlayerProvider>");
  }
  return context;
}

export function VideoPlayerProvider({ children }: { children: ReactNode }) {
  const [source, setSource] = useState<VideoSource | null>(null);
  const videoRef = useRef<HTMLVideoElement>(null);

  const play = useCallback((next: VideoSource) => setSource(next), []);

  const close = useCallback(() => {
    videoRef.current?.pause();
    setSource(null);
  }, []);

  useEffect(() => {
    if (!source) return;

    const videoEl = videoRef.current;
    if (!videoEl) return;

    videoEl.currentTime = 0;
    void videoEl.play().catch(() => {});
  }, [source]);

  useEffect(() => {
    if (!source) return;

    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") close();
    };

    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    window.addEventListener("keydown", handleKeyDown);

    return () => {
      document.body.style.overflow = previousOverflow;
      window.removeEventListener("keydown", handleKeyDown);
    };
  }, [source, close]);

  return (
    <VideoPlayerContext.Provider value={{ play }}>
      {children}

      {source ? (
        <div
          role="dialog"
          aria-modal="true"
          aria-label={`${source.title} preview`}
          onClick={(event) => {
            if (event.target === event.currentTarget) close();
          }}
          className="fixed inset-0 z-[100] flex items-center justify-center bg-black/85 backdrop-blur-sm p-4"
        >
          <div className="relative w-full max-w-4xl">
            <button
              type="button"
              onClick={close}
              aria-label="Close video"
              className="absolute -top-12 right-0 flex items-center gap-1 text-white/80 hover:text-white font-label-md text-label-md transition-colors"
            >
              <X aria-hidden="true" size={24} />
              Close
            </button>

            <video
              ref={videoRef}
              src={source.video}
              poster={source.poster}
              controls
              autoPlay
              playsInline
              className="w-full aspect-video rounded-xl bg-black shadow-[0_20px_60px_rgba(0,0,0,0.8)]"
            />

            <div className="mt-3 flex flex-col gap-0.5">
              <h3 className="font-headline-md text-headline-md text-white font-bold">
                {source.title}
              </h3>
              {source.meta ? (
                <p className="font-body-sm text-body-sm text-on-surface-variant">
                  {source.meta}
                </p>
              ) : null}
            </div>
          </div>
        </div>
      ) : null}
    </VideoPlayerContext.Provider>
  );
}
