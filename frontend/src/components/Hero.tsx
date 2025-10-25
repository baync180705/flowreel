import { Play, Sparkles, Shield, Coins } from "lucide-react";
import { Button } from "@/components/ui/button";

export const Hero = () => {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
      {/* Animated background */}
      <div className="absolute inset-0 bg-gradient-hero opacity-50" />
      <div className="absolute inset-0">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-primary/20 rounded-full blur-3xl animate-pulse" />
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-secondary/20 rounded-full blur-3xl animate-pulse delay-1000" />
      </div>

      <div className="container mx-auto px-4 relative z-10">
        <div className="max-w-4xl mx-auto text-center space-y-8 animate-fade-in">
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-card/50 backdrop-blur-sm border border-primary/20">
            <Sparkles className="h-4 w-4 text-primary" />
            <span className="text-sm font-medium">Powered by Flow Blockchain</span>
          </div>

          <h1 className="text-5xl sm:text-6xl lg:text-7xl font-bold leading-tight">
            The Future of
            <br />
            <span className="bg-gradient-neon bg-clip-text text-transparent">
              Decentralized Cinema
            </span>
          </h1>

          <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
            Rent or own movies as NFTs. Support verified creators directly. 
            Experience the blockchain-powered movie platform with anti-piracy protection.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <Button size="lg" className="gap-2 bg-gradient-neon text-lg px-8 py-6 shadow-neon hover:shadow-glow transition-all">
              <Play className="h-5 w-5" fill="currentColor" />
              Start Watching
            </Button>
            <Button size="lg" variant="outline" className="text-lg px-8 py-6 border-primary/50 hover:bg-primary/10">
              Learn More
            </Button>
          </div>

          {/* Feature highlights */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 pt-12">
            <div className="p-6 rounded-xl bg-card/30 backdrop-blur-sm border border-border/50 hover:border-primary/50 transition-all">
              <Shield className="h-10 w-10 text-primary mb-4 mx-auto" />
              <h3 className="font-semibold mb-2">Verified Creators</h3>
              <p className="text-sm text-muted-foreground">Only trusted creators can upload content</p>
            </div>
            <div className="p-6 rounded-xl bg-card/30 backdrop-blur-sm border border-border/50 hover:border-secondary/50 transition-all">
              <Coins className="h-10 w-10 text-secondary mb-4 mx-auto" />
              <h3 className="font-semibold mb-2">NFT Access</h3>
              <p className="text-sm text-muted-foreground">Rent or buy movies with blockchain ownership</p>
            </div>
            <div className="p-6 rounded-xl bg-card/30 backdrop-blur-sm border border-border/50 hover:border-verified/50 transition-all">
              <Sparkles className="h-10 w-10 text-verified mb-4 mx-auto" />
              <h3 className="font-semibold mb-2">Anti-Piracy</h3>
              <p className="text-sm text-muted-foreground">Advanced protection with onchain verification</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};
