import { CheckCircle2, Upload, Wallet, Eye, Zap } from "lucide-react";

const steps = [
  {
    icon: CheckCircle2,
    title: "Creator Verification",
    description: "New creators get verified through admin approval or DAO voting to ensure quality content.",
    color: "text-verified",
  },
  {
    icon: Upload,
    title: "Upload & Hash",
    description: "Creators upload movies with cryptographic hashing and signature verification for authenticity.",
    color: "text-primary",
  },
  {
    icon: Wallet,
    title: "Mint MovieNFTs",
    description: "Viewers rent or buy movies, receiving NFTs as access keys with automated payments via Flow Actions.",
    color: "text-secondary",
  },
  {
    icon: Eye,
    title: "Watch Securely",
    description: "Stream encrypted movies from IPFS with watermarking and NFT-based access control.",
    color: "text-accent",
  },
  {
    icon: Zap,
    title: "Flow Agents",
    description: "Automated tasks handle rental expiry, payouts, and subscription renewals - fully autonomous.",
    color: "text-primary",
  },
];

export const HowItWorks = () => {
  return (
    <section className="py-24 relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-hero opacity-20" />
      
      <div className="container mx-auto px-4 relative z-10">
        <div className="text-center mb-16 space-y-4">
          <h2 className="text-4xl sm:text-5xl font-bold">
            How It <span className="bg-gradient-neon bg-clip-text text-transparent">Works</span>
          </h2>
          <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
            A seamless blockchain-powered workflow from creation to consumption
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 max-w-6xl mx-auto">
          {steps.map((step, index) => {
            const Icon = step.icon;
            return (
              <div
                key={index}
                className="relative p-8 rounded-2xl bg-card/50 backdrop-blur-sm border border-border/50 hover:border-primary/50 transition-all group"
              >
                <div className="absolute -top-4 -left-4 w-12 h-12 rounded-xl bg-background border border-border flex items-center justify-center font-bold text-lg group-hover:scale-110 transition-transform">
                  {index + 1}
                </div>
                
                <Icon className={`h-12 w-12 ${step.color} mb-4`} />
                <h3 className="text-xl font-semibold mb-3">{step.title}</h3>
                <p className="text-muted-foreground leading-relaxed">{step.description}</p>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
};
