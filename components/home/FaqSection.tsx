"use client";

import { useState } from "react";
import { ChevronDown } from "lucide-react";

import { FAQS } from "@/data/landing";

export default function FaqSection() {
  const [openId, setOpenId] = useState<string | null>(null);

  return (
    <section className="flex flex-col gap-space-lg max-w-4xl mx-auto w-full pt-space-lg">
      <div className="text-center flex flex-col gap-space-xs">
        <h2 className="font-headline-lg-mobile md:text-headline-lg font-headline-lg text-white">
          Frequently Asked Questions
        </h2>
        <p className="font-body-md text-body-md text-on-surface-variant">
          Have questions about streaming Nepali cinema? We have answers.
        </p>
      </div>

      <div className="flex flex-col gap-space-sm">
        {FAQS.map((faq) => {
          const isOpen = openId === faq.id;
          return (
            <div
              key={faq.id}
              className="rounded-xl bg-surface-container overflow-hidden"
            >
              <button
                type="button"
                aria-expanded={isOpen}
                aria-controls={`faq-${faq.id}`}
                onClick={() => setOpenId(isOpen ? null : faq.id)}
                className="w-full p-space-md flex items-center justify-between gap-space-md text-left hover:bg-surface-container-high transition-colors"
              >
                <span className="font-headline-sm text-headline-sm text-white font-semibold">
                  {faq.question}
                </span>
                <ChevronDown
                  aria-hidden="true"
                  size={24}
                  className={`flex-none text-on-surface-variant transition-transform duration-200 ${
                    isOpen ? "rotate-180" : ""
                  }`}
                />
              </button>
              {isOpen ? (
                <div
                  id={`faq-${faq.id}`}
                  className="px-space-md pb-space-md font-body-md text-body-md text-on-surface-variant"
                >
                  {faq.answer}
                </div>
              ) : null}
            </div>
          );
        })}
      </div>
    </section>
  );
}
