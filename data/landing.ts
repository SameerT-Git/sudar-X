
const AIDA = "https://lh3.googleusercontent.com/aida-public/";
const img = (id: string) => `${AIDA}${id}`;

const SAMPLE_VIDEOS = [
  "https://media.w3.org/2010/05/sintel/trailer.mp4",
  "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4",
  "https://vjs.zencdn.net/v/oceans.mp4",
  "https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4",
  "https://test-videos.co.uk/vids/jellyfish/mp4/h264/720/Jellyfish_720_10s_1MB.mp4",
  "https://interactive-examples.mdn.mozilla.net/media/cc0-videos/friday.mp4",
  "https://test-videos.co.uk/vids/sintel/mp4/h264/720/Sintel_720_10s_1MB.mp4",
  "https://media.w3.org/2010/05/bunny/trailer.mp4",
  "https://media.w3.org/2010/05/video/movie_300.mp4",
] as const;

const video = (index: number) => SAMPLE_VIDEOS[index % SAMPLE_VIDEOS.length];

export const HERO = {
  backdrop: img(
    "AB6AXuBTnLaQzahpRw1izUS_57-LKW_rgro5NanLtVUqBuRWVOnOyjJf08XMxDdz5sk1PQSijASBJAf-fL34H7bSD_jVK4RI8SLz9lbbC3Gw-0-Sc6YnYlU9wla-_TRvUEGoE0I3lBzbCPLB8SUzLo6LYEf9VYqKORxRnkVRgeQ1IghMOKdYfm2VY5OiN2J3GIq9dqsPEX0_oLFQwFP4wk_yt2das2CoKf9pMBzzN5spG3rN",
  ),
  video: video(0),
  badges: {
    premiere: "Exclusive Premiere",
    quality: "4K ULTRA HD • DOLBY ATMOS",
    rank: "#1 IN NEPAL TODAY",
    nepali: "नेपाली मौलिक चलचित्र",
  },
  title: "SHAMBHALA",
  subtitle: "The Lost Valley of Mustang",
  rating: "8.9",
  ratingSource: "(IMDb)",
  duration: "2h 24m",
  year: "2025",
  certificate: "U/A 16+",
  genres: "Himalayan Epic • Mythological Thriller • Adventure",
  synopsis:
    "When an ancient Buddhist relic is stolen from an isolated monastery above the trans-Himalayan gorge, a rebellious high-altitude nomad and a silent monk must race through blizzards to restore the cosmic equilibrium of the sacred valley.",
} as const;

export type FeaturedItem = {
  id: string;
  title: string;
  note: string;
  progress: number;
  playing?: boolean;
};

export const FEATURED_SWITCHER: readonly FeaturedItem[] = [
  {
    id: "shambhala",
    title: "1. Shambhala: The Lost Valley",
    note: "NOW PLAYING",
    progress: 75,
    playing: true,
  },
  {
    id: "ainaa",
    title: "2. Ainaa Jhyal Ko Putali",
    note: "4K UHD",
    progress: 0,
  },
  {
    id: "kabbadi",
    title: "3. Kabbadi 4: The Final Match",
    note: "BLOCKBUSTER",
    progress: 0,
  },
  {
    id: "underbelly",
    title: "4. Kathmandu Underbelly S2",
    note: "ORIGINAL",
    progress: 0,
  },
];

export type BadgeTone = "primary" | "muted" | "error";

export type TrendingTitle = {
  id: string;
  rank: number;
  title: string;
  meta: string;
  badge?: { label: string; tone: BadgeTone };
  poster: string;
  video: string;
};

export const TRENDING_IN_NEPAL: readonly TrendingTitle[] = [
  {
    id: "kabbadi-4",
    rank: 1,
    title: "Kabbadi 4: The Final",
    meta: "Rom-Com • 2h 12m • 4K HDR",
    badge: { label: "#1 TRENDING", tone: "primary" },
    poster: img(
      "AB6AXuAbaa8rAuv0hdNmNeteycQthmlLzdc6UtctLbx83zGMjjlpTfGpJ-HzixGsfQwHI92VHXe4W7NPY_zUNhhvxRt-W6Nrch1jRiV_FozxeN2X31LbuodCzOYfEzUsHuS9YvEMRZ8BdjplEt1mDbqrX-ywA1m6tdL8QYOemp0Ot__Hooxh6W_SF2hb_xFPAKhruMfrH71f5U7VyHXk4lDNS79pQ5hAR3SH78vkAhdVOxK5",
    ),
    video: video(0),
  },
  {
    id: "jari",
    rank: 2,
    title: "Jari",
    meta: "Cultural Drama • 2h 08m",
    badge: { label: "POPULAR", tone: "muted" },
    poster: img(
      "AB6AXuA3VK9fm0f6Ke00Eqh8PHVr5Bv0CPDdvl13h-4SLaqwgdmYEYgrfBQycrpsKzOjJMaZX5bj_KaxzZGGVkemJq0HHb6LjRuX523d2TF5aTDgy_mubJEtqQXWepAAzWDDR1XKkV-096MzJfVba3BEXJijZsaWJfPS3cVnfMsN8ns8eQvwaZWD1S3-2-VYPgd6jWeZZ0qa99SsrRrrfjYZy9giZefozCJqaitBRPL_95D5",
    ),
    video: video(1),
  },
  {
    id: "mahapurush",
    rank: 3,
    title: "Mahapurush",
    meta: "Family Drama • 2h 30m",
    badge: { label: "AUDIENCE CHOICE", tone: "muted" },
    poster: img(
      "AB6AXuCBKkOCBwlzvnOTI-853zYBOSk1fGA4FVeu2zS7V5DY0rUeAwd1G-ACtkZtefrHDUeQ43aWZGixR1f9g4Ec9euuPYEFDQSoWrC8abqhc1xYuw95FFzi4czaQzJ4t7bY_32NpfPPiu3g5B_V25w7PHUGt_JgTye5RqNeCGzO6TmDtYXwYRmjpYjDTtTJ6bTHgqZNNgXH1n0SyjwMnSnFG5zH9yWZpBdc2VjSOTzNEKUP",
    ),
    video: video(2),
  },
  {
    id: "boksi-ko-ghar",
    rank: 4,
    title: "Boksi Ko Ghar",
    meta: "Psychological • 1h 55m",
    badge: { label: "THRILLER", tone: "error" },
    poster: img(
      "AB6AXuBgpaLMD9Cec38KYALpIRRIAjUtfvLpdb4ulLCdoOS07PUHbnHY83ELVSqEl9gXUdlGYySoiI4lS011EXPmLeIeB_fnwK512VvrEQt3GPrDI1T-ztTK71NdxUvAFYUeHl-18WpJCas7y9vzGLy5JeUCXCsu5suBkYqR3bHvNuANKK4jhXMab1LGsLnCDKCPw0DW2O9zt9ekJXy6wDwk4Y8nWnPprQrgu198jpKPy1As",
    ),
    video: video(3),
  },
  {
    id: "chhakka-panja-5",
    rank: 5,
    title: "Chhakka Panja 5",
    meta: "Social Comedy • 2h 18m",
    poster: img(
      "AB6AXuAaw25bQIoQv9bKeVpEs0zyiXWoRcJRaFqT5VROBgwhregAOyIn_aStrJWweo-QF4LKhvqFpuaXhTCnmgg6criDCHqJKnV6PMJqDv5uxjr9V1Kzkw3Yi40YqssA-N-4VHbMwWkquyhaKfOiozxXZaB-aUUxz2sFA1Yud2CauhKLdKT1BTN0uYN_xj8eKSJNJbL5JFWvkLr2gYgmu8GPgWH7QSVNbj6Ivh1U6_YieWO0",
    ),
    video: video(4),
  },
  {
    id: "degree-maila",
    rank: 6,
    title: "Degree Maila",
    meta: "Satire • 2h 05m",
    poster: img(
      "AB6AXuD_zsHbc3ZkYZx0lp4dt0UMM25nmCzWiEzQP6VpLVgadG_OksshRStxsl08mcu-RzECjkGcK4AGXgPozfj0utD5c8evauJrSPi2MlhcUaRG3w9IEdXP-5W-Jsuala_bSRyb0FAc2L6fy2Az6olqzA273x0zXE_TYWZprILVFSwLojouoW_9UMbI-VwU4YxslUpKo8M-d8B2XYwqk4tGqehqEL1MG2arKzUOXopI_p_y",
    ),
    video: video(5),
  },
];

export type SpotlightTitle = {
  id: string;
  title: string;
  award: string;
  awardTone: "muted" | "primary";
  score: string;
  synopsis: string;
  meta: readonly string[];
  poster: string;
  video: string;
};

export const NEPAL_SPOTLIGHT: readonly SpotlightTitle[] = [
  {
    id: "ainaa-jhyal-ko-putali",
    title: "Ainaa Jhyal Ko Putali",
    award: "Oscars Entry 2023",
    awardTone: "muted",
    score: "99%",
    synopsis:
      "Butterfly on the Windowpane: An endearing story of a gifted village sister longing for schooling amidst remote social constraints.",
    meta: ["FESTIVAL CUT", "1h 36m", "Dolby Vision"],
    poster: img(
      "AB6AXuDOcP0636ZmCBeQYPrvlJzKIleElpp-O0YX_U2HwMtzWtRi39TlKIQBUydRNxEQEuPBjL7DPrOuaK2vcFQI5NLc_vQIwxjbw0D2tyTTnJZzreY-fUh9_JlYvfVmJlHcLAvR7cPUAQs9uQwN8vkoEcVzKEQY1N1_3eT2ENtB62dmqIa1Tt8OaKEc5QpM_ZiZj0SEL-YeUzvqFM2v_eh9pBt_ArWfa-ABU8FoijgpXzSB",
    ),
    video: video(1),
  },
  {
    id: "kalo-pothi",
    title: "Kalo Pothi (The Black Hen)",
    award: "Venice Critics Week",
    awardTone: "muted",
    score: "97%",
    synopsis:
      "In war-torn northern Nepal, two innocent boys set off on an audacious mission to retrieve their stolen companion hen.",
    meta: ["VENICE WINNER", "1h 30m", "HDR10"],
    poster: img(
      "AB6AXuBxcjavX_cK3g5Lp5MwUVzZf7MeW3cOo0hVFy7uxyEUkqEe8zlrXzs-HKjZRzpQIhJIrxhfwYT9yzfGJTjDcHvJLESqWECIDZmn_3LGJPbusZb2KpbVJeTLvT9BVSzOOf03i4uOk4tIsgx24Y0jtIa4MpzsoIeTgwKZ3LFKfUc2BAYyo8AAJJa1HX41X1RvZ3SjQyo7HwhXVxU8GtiasDa5LjB36_cyBIoPlK9V9u76",
    ),
    video: video(2),
  },
  {
    id: "seto-surya",
    title: "Seto Surya (White Sun)",
    award: "Venice / Toronto IFF",
    awardTone: "muted",
    score: "95%",
    synopsis:
      "Deep political fractures and generational reconciliation unfold around a father's mountain burial ceremony.",
    meta: ["AWARD WINNER", "1h 29m", "5.1 Audio"],
    poster: img(
      "AB6AXuC6u-zQd11maesz9YiuY7f-zHBDYp4UrcOcLs5twnZ6-Fxxb7psobaYA7Zgpfs1HSH93EkbBO84gswCoMj5SVWYPnEsJUNc-bgdMHXrIDAH0UBhxjT9uXeY3OQGzMtA4puzwYoN4lMrHdOFP40ldF_tdhQg7C3lS6dxst0ftXWvD6J1td2F6wznEK374h9mhUkM1UYPoRv5a8Rurq6jVjvH3CoQ7vPoqsoeoixaifum",
    ),
    video: video(3),
  },
  {
    id: "prakash",
    title: "Prakash (The Teacher)",
    award: "National Award",
    awardTone: "primary",
    score: "93%",
    synopsis:
      "A moving struggle of an impoverished youth in Jumla striving to qualify through civil service exams to uplift his mother.",
    meta: ["ORIGINAL", "2h 10m", "Dolby Atmos"],
    poster: img(
      "AB6AXuCtSLJh1HUXha1F2KNvquz5gOV-uZ3ctZLWo-1IQJlXyk0d7UREzwqHhTzD8Sj8tCe1AHeM6cofzua1cTxoJ1YslF6e1rxjaYzCCmbm7h0uxrReHGoc50QjV9kzmNj9NSqNUWE4UjbGkr_ziMVBR0ky_IZyt7GczzMCMT3NJWGUbvn77vYq9Cj1lfjNOjOgmB5XJ3_9aDJHReGRa_OqTDkkpea530RtXDbOSeKYTzpK",
    ),
    video: video(4),
  },
];

export type SeriesItem = {
  id: string;
  title: string;
  tag: string;
  tagClass: string;
  episodes: string;
  poster: string;
  video: string;
};

export const ORIGINAL_SERIES: readonly SeriesItem[] = [
  {
    id: "singhadurbar",
    title: "Singhadurbar",
    tag: "SEASON 2",
    tagClass: "bg-primary-container text-white",
    episodes: "10 Episodes",
    poster: img(
      "AB6AXuD9d5za3emqo25FZExnEn0i4r5epXatKYmmKrnVXjz11RXY77utAUBmdBgjiY3vpPqc18D9vOtd4gHfTg1vnsowPuqfowz3jI5rLM6G_SQpGq7fa4oqQmQE3J2x96s-ZQ5uYqa7CJPWCZTq3kg8c5rAJLUeOUzyY77JYChZohb7mwahz4pz8Ih43g8c1LV6nHndHh7qMNsmgq4LEroeO2z47OcFjzueyUB9DOjtsaa-",
    ),
    video: video(0),
  },
  {
    id: "kathmandu-underbelly",
    title: "Kathmandu Underbelly",
    tag: "NEW",
    tagClass: "bg-primary-container text-white",
    episodes: "8 Episodes",
    poster: img(
      "AB6AXuDrXM2q-XyjWTkIfoHiRFurKI033i2ILawKtmC9WT_uTEY2KIei64yS12nEuemGZ-5hNt5zBVKB-bjbK-7NDdJjiBMdTp_VfJWr_Pa44uH4NOoJL0hdjAKoUCqadjaFTCC6FJqjq9kVYeXP6K27JjmOwQoiDzsZjWzF_4CbBuoBq9UiA8Mi1VQFFWxwhABLW5rlCuT4QWKtzRZQejADKzFhiAdF-K9cu-0ff9Imrnvg",
    ),
    video: video(1),
  },
  {
    id: "sherpa-icefall-lords",
    title: "Sherpa: Icefall Lords",
    tag: "DOCUSERIES",
    tagClass: "bg-secondary-container text-white",
    episodes: "6 Episodes",
    poster: img(
      "AB6AXuCYq1r96vEclQAexLWwp2aM5Rhfo1HH0Z8GckeO8orFkoOwL93H8a-fvfqqbnou7R5ms63V0_igMCeOcPVguU8P_2R7xjZffhVSQOL2L8v9singQiD5hdoCTcEmeD2X-CSDZ8tQ5TwZ2envGcUjyzBGrd3n4vpPqhNh-sk9DzQDqCFQwz7xs9guC4An6Sr_Hcb9KurAW6xfS72y-WrsYk1gxUHJuQdXit2k8D4L_-bW",
    ),
    video: video(2),
  },
  {
    id: "harke-hawaldar",
    title: "Harke Hawaldar HD",
    tag: "REMASTERED",
    tagClass: "bg-surface-variant text-white",
    episodes: "50+ Episodes",
    poster: img(
      "AB6AXuDlI8jDjs0T6TbSY_qBrcmd-ogA9ghki3Z1YlftuWoffAKuFokrOPdgn50xR40SFzStnSn_H1cRJ8WVwE5qa9FIAO1x7ikq_wRZiUSCgG2czG21BaBGhiBXLDdgcUh8nMTyKZdhDqqjRPoJVgN_Y6a4j2ySHJ7dsgsLfOVEAaIW4LUXMY3CvUVk5p5_xluqAK_Kf58x9v9_9HThALwjNAu58lFzPljXrpaW-_po6mKJ",
    ),
    video: video(3),
  },
  {
    id: "kathmandu-melodies",
    title: "Kathmandu Melodies",
    tag: "ORIGINAL",
    tagClass: "bg-primary-container text-white",
    episodes: "7 Episodes",
    poster: img(
      "AB6AXuBtfgUQTLy4EpCrYnIqC4FzaYzq0aCmkT0XOszqG9S0Nvq45er9UAeP3Vc2idDWBmefj5RndsXoWHSmk4eC1bbuScA1vqP1Pi48nIwIJuraaTwznAk82bBiqHnG-Gwgr2oRgk7DUwweFuztJwvN2M9ghLGLUSmSsOIsNBE4UryAiQRbot4GNhXJYuMVZ-BS3nTfzD9AkWy7Qcu3KqLYmxtpMzn7WUHtnCKXm3CWVEXd",
    ),
    video: video(4),
  },
  {
    id: "lakeside-nightmares",
    title: "Lakeside Nightmares",
    tag: "HORROR",
    tagClass: "bg-error-container text-white",
    episodes: "5 Episodes",
    poster: img(
      "AB6AXuCRYvfRIHtl4Htpsmf6s3UCCYw9Fe40fP16iqF_Gi1K1i8H8as-OgWCKDG5MKWp7hWQUWpOX99wCFyPk8LeyvdaXectRqcREhKOyncsapJTyNIGAFjt8dCBrAZbYN6Ww3zUpVpotkjJFm_hS1LNySE0P-Cxp2j7lbX0qweEUVFsYw4CbInf1S2yvIfzdbSUkvm-JrUdyqnoZVvYLqd_93Pe7z7XEnWJ_UXbNhR4Qx1k",
    ),
    video: video(5),
  },
];

export const EDITORIAL = {
  eyebrow: "Worldwide Cultural Streaming",
  heading: "Celebrating Nepali Stories on the Global Stage",
  body: "From timeless nostalgic classics by Tulsi Ghimire to revolutionary contemporary visions by modern creators. SudarX bridges over 30 million Nepalis worldwide with flawless 4K high-bitrate streaming.",
  image: img(
    "AB6AXuB2VQcStjr-Y4vrhDJxwC1V1Xnch4bYDmasfFdYqE2DDNDMXT5ZJXMzj3e-xw0zp3LZ27LneWF6d_FGstAmyRNJA_yVVeks4cu9B9nEe-GvGf5L8NKukluHn5-51iF3K0CuVVn1PQJDWrUdm53fA2TWUa9QSrjRXmLUixThNc1BfhAfJBpy3JvR8g1kBUJPqBltWYRbV745Fxzkc0ASSmdRaWcJlnztr-rh1hs6GseL",
  ),
  hubs: "Kathmandu • Dallas • Sydney • London",
  stats: [
    { value: "600+", label: "Nepali Titles", tone: "text-white" },
    { value: "100%", label: "Ad-Free Viewing", tone: "text-primary" },
    { value: "4K Atmos", label: "Remastered Audio", tone: "text-secondary" },
    { value: "150+", label: "Global Nations", tone: "text-white" },
  ],
} as const;

export type PillarIcon =
  | "wallet"
  | "hd"
  | "voices"
  | "screens"
  | "download";

export type ValuePillar = {
  id: string;
  icon: PillarIcon;
  tone: "primary" | "secondary";
  title: string;
  body: string;
};

export const VALUE_PILLARS: readonly ValuePillar[] = [
  {
    id: "affordable",
    icon: "wallet",
    tone: "primary",
    title: "Affordable Plans",
    body: "Starting at only Rs. 199/month. Seamless payment via eSewa, Khalti, ConnectIPS and Cards.",
  },
  {
    id: "quality",
    icon: "hd",
    tone: "secondary",
    title: "4K HDR & Atmos",
    body: "Uncompressed dynamic colors and spatial Dolby audio mixed exclusively for soundbars and home theaters.",
  },
  {
    id: "voices",
    icon: "voices",
    tone: "primary",
    title: "Authentic Voices",
    body: "From remote Karnali stories to Newari heritage sagas. 100% curated Nepali indigenous cinema.",
  },
  {
    id: "screens",
    icon: "screens",
    tone: "secondary",
    title: "All Your Screens",
    body: "Instant sync across iPhone, Android, Google TV, Apple TV, Roku, fireTV, and desktop browsers.",
  },
  {
    id: "offline",
    icon: "download",
    tone: "primary",
    title: "Offline Downloads",
    body: "Download your watchlist over Wi-Fi and watch during travel, trekking trails, or power outages.",
  },
];

export type PlanFeature = {
  label: string;
  included: boolean;
  highlight?: boolean;
};

export type Plan = {
  id: string;
  name: string;
  tagline: string;
  price: string;
  popular?: boolean;
  features: readonly PlanFeature[];
  cta: string;
};

export const PLANS: readonly Plan[] = [
  {
    id: "mobile",
    name: "Mobile",
    tagline: "Perfect for personal viewing on phone & tablet",
    price: "199",
    features: [
      { label: "1 Mobile or Tablet Screen", included: true },
      { label: "720p HD Quality", included: true },
      { label: "Download on 1 Device", included: true },
      { label: "TV & Laptop Access", included: false },
    ],
    cta: "Choose Mobile",
  },
  {
    id: "standard",
    name: "Standard",
    tagline: "Great balance for couples and small households",
    price: "399",
    popular: true,
    features: [
      { label: "2 Screens Simultaneously", included: true },
      { label: "1080p Full HD Resolution", included: true },
      { label: "TV, Laptop, Tablet & Phone", included: true },
      { label: "Download on 2 Devices", included: true },
    ],
    cta: "Start 7-Day Free Trial",
  },
  {
    id: "premium",
    name: "Premium 4K Family",
    tagline: "Ultimate theater-grade cinema experience",
    price: "599",
    features: [
      { label: "4 Concurrent Streams", included: true },
      { label: "4K Ultra HD + Dolby Atmos", included: true, highlight: true },
      { label: "Spatial Audio Surround", included: true },
      { label: "Early Access to Premieres", included: true },
    ],
    cta: "Choose Premium",
  },
];

export const PAYMENT_METHODS = [
  "eSewa",
  "Khalti",
  "IME Pay",
  "ConnectIPS",
  "Visa / Mastercard",
] as const;

export type Faq = { id: string; question: string; answer: string };

export const FAQS: readonly Faq[] = [
  {
    id: "what-is-sudarx",
    question: "What is SudarX and what can I watch?",
    answer:
      "SudarX is the premier global OTT streaming destination for Nepali cinema. You get unlimited access to box office blockbusters, award-winning indie festival movies, original episodic series, golden era remastered classics, and live cultural events in pristine 4K HDR.",
  },
  {
    id: "outside-nepal",
    question: "Can I watch outside of Nepal (in the US, Australia, UK)?",
    answer:
      "Yes! SudarX is globally available across more than 150 countries. International viewers can subscribe securely using international credit/debit cards, PayPal, or Google/Apple in-app subscriptions with no geographical VPN blocks on global titles.",
  },
  {
    id: "esewa-khalti",
    question: "How do I pay with eSewa or Khalti?",
    answer:
      "During checkout, simply select either eSewa, Khalti, or IME Pay. You will be redirected to complete your biometric OTP authentication. Once verified, your subscription is activated immediately with instant renewal controls.",
  },
  {
    id: "smart-tv",
    question: "How do I install SudarX on my Smart TV?",
    answer:
      'Open the Google Play Store on your Android TV, Sony, TCL, or Xiaomi TV, search for "SudarX", and click Install. On Apple TV or Fire TV, download the SudarX TV app. You can then quickly log in by scanning an on-screen QR code with your smartphone.',
  },
];
