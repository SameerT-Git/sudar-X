"use client";

import { useState } from "react";
import Link from "next/link";
import { ArrowRight, Eye, EyeOff, Lock, Mail } from "lucide-react";

export default function AdminLogin() {
  const [showPassword, setShowPassword] = useState(false);

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
  }

  return (
    <div className="w-full max-w-[520px] relative z-10">
      <div className="bg-surface-container-low/90 backdrop-blur-2xl rounded-xl p-6 sm:p-10 shadow-2xl relative overflow-hidden border border-surface-container-highest/30">
        <div className="absolute inset-x-0 top-0 h-[2px] bg-gradient-to-r from-transparent via-primary-container/80 to-transparent" />

        <div className="space-y-1 mb-6 text-left">
          <h1 className="font-headline-lg text-headline-lg text-on-surface tracking-tight">
            Admin Sign In
          </h1>
          <p className="font-body-md text-body-md text-on-surface-variant">
            Enter your credentials to access the management portal
          </p>
        </div>

        <form className="space-y-4" onSubmit={handleSubmit}>
          <div className="space-y-1">
            <label
              className="block font-label-md text-label-md text-on-surface"
              htmlFor="adminEmail"
            >
              Work Email or Admin ID
            </label>
            <div className="relative flex items-center">
              <Mail
                aria-hidden="true"
                size={20}
                className="absolute left-3.5 text-tertiary-container pointer-events-none"
              />
              <input
                className="w-full bg-surface-container-lowest text-on-surface font-body-md text-body-md pl-11 pr-4 py-3 rounded-lg border border-surface-container-highest/60 focus:outline-none focus:ring-1 focus:ring-primary-container transition-all placeholder:text-tertiary-container/60 shadow-inner"
                id="adminEmail"
                name="email"
                placeholder="name@sudarx.com"
                required
                type="email"
                autoComplete="username"
              />
            </div>
          </div>

          <div className="space-y-1">
            <div className="flex justify-between items-center">
              <label
                className="block font-label-md text-label-md text-on-surface"
                htmlFor="adminPassword"
              >
                Password
              </label>
              <Link
                href="#"
                className="font-body-sm text-body-sm text-primary hover:underline"
              >
                Forgot password?
              </Link>
            </div>
            <div className="relative flex items-center">
              <Lock
                aria-hidden="true"
                size={20}
                className="absolute left-3.5 text-tertiary-container pointer-events-none"
              />
              <input
                className="w-full bg-surface-container-lowest text-on-surface font-body-md text-body-md pl-11 pr-12 py-3 rounded-lg border border-surface-container-highest/60 focus:outline-none focus:ring-1 focus:ring-primary-container transition-all placeholder:text-tertiary-container/60 shadow-inner"
                id="adminPassword"
                name="password"
                placeholder="••••••••••••"
                required
                type={showPassword ? "text" : "password"}
                autoComplete="current-password"
              />
              <button
                aria-label={showPassword ? "Hide password" : "Show password"}
                className="absolute right-3 text-tertiary-container hover:text-on-surface transition-colors p-1 cursor-pointer"
                onClick={() => setShowPassword((v) => !v)}
                type="button"
              >
                {showPassword ? (
                  <EyeOff aria-hidden="true" size={20} />
                ) : (
                  <Eye aria-hidden="true" size={20} />
                )}
              </button>
            </div>
          </div>

          <div className="flex items-center justify-between pt-1">
            <label className="flex items-center gap-2 cursor-pointer select-none group">
              <input
                defaultChecked
                className="w-4 h-4 rounded bg-surface-container-lowest cursor-pointer accent-[#dc143c]"
                name="rememberMe"
                type="checkbox"
              />
              <span className="font-body-sm text-body-sm text-on-surface-variant group-hover:text-on-surface transition-colors">
                Remember me
              </span>
            </label>
          </div>

          <div className="pt-2">
            <button
              className="w-full flex items-center justify-center gap-2 py-3 px-6 rounded-lg bg-primary-container text-on-primary-container font-label-lg text-label-lg tracking-wide hover:brightness-110 active:scale-[0.99] transition-all shadow-[0_12px_24px_-6px_rgba(220,20,60,0.45)] cursor-pointer group"
              type="submit"
            >
              <span>Sign In</span>
              <ArrowRight
                aria-hidden="true"
                size={18}
                className="group-hover:translate-x-1 transition-transform"
              />
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
