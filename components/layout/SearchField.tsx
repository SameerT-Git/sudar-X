"use client";

import { useState } from "react";
import type { FormEvent } from "react";
import { useRouter } from "next/navigation";
import { Search } from "lucide-react";

type SearchFieldProps = {
  className?: string;
};

export default function SearchField({ className = "" }: SearchFieldProps) {
  const router = useRouter();
  const [query, setQuery] = useState("");

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const searchTerm = query.trim();
    if (!searchTerm) return;

    router.push(`/search?q=${encodeURIComponent(searchTerm)}`);
    setQuery("");
  }

  return (
    <form
      role="search"
      onSubmit={handleSubmit}
      className={`items-center bg-surface-container-low rounded-full px-space-sm py-space-xs ${className}`}
    >
      <button
        type="submit"
        aria-label="Search catalog"
        className="w-8 h-8 flex-none flex items-center justify-center text-on-surface-variant hover:text-on-surface transition-colors"
      >
        <Search aria-hidden="true" size={20} />
      </button>
      <input
        type="search"
        name="q"
        value={query}
        onChange={(event) => setQuery(event.target.value)}
        placeholder="Search titles, genres, actors..."
        aria-label="Search titles, genres, actors..."
        className="bg-transparent border-none outline-none font-body-sm text-body-sm text-on-surface placeholder:text-outline-variant w-full min-w-0 pr-space-sm"
      />
    </form>
  );
}
