import { Navbar } from "@/components/Navbar";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { useParams } from "react-router-dom";
import { Play, Clock, ShoppingCart, Wallet, Shield, Hash } from "lucide-react";

const MovieDetail = () => {
  const { id } = useParams();

  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      
      <main className="pt-16">
        {/* Hero Section */}
        <div className="relative h-[70vh] overflow-hidden">
          <img
            src="https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=1920&h=1080&fit=crop"
            alt="Movie backdrop"
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-background via-background/50 to-transparent" />
        </div>

        <div className="container mx-auto px-4 -mt-32 relative z-10">
          <div className="grid lg:grid-cols-3 gap-8">
            {/* Movie Poster */}
            <div className="lg:col-span-1">
              <img
                src="https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=400&h=600&fit=crop"
                alt="Movie poster"
                className="w-full rounded-2xl shadow-card border border-border/50"
              />
            </div>

            {/* Movie Info */}
            <div className="lg:col-span-2 space-y-6">
              <div>
                <div className="flex items-center gap-3 mb-3">
                  <Badge variant="outline" className="border-verified text-verified">
                    Verified Creator
                  </Badge>
                  <Badge variant="secondary" className="gap-1">
                    <Clock className="h-3 w-3" />
                    2h 15m
                  </Badge>
                </div>
                <h1 className="text-5xl font-bold mb-4">Cosmic Odyssey</h1>
                <p className="text-xl text-muted-foreground">by StellarFilms</p>
              </div>

              <p className="text-lg text-foreground/90 leading-relaxed">
                Embark on a breathtaking journey through the cosmos in this epic space adventure. 
                When a crew of explorers discovers an ancient alien artifact, they must unravel 
                its mysteries before time runs out.
              </p>

              {/* Purchase Options */}
              <div className="grid sm:grid-cols-2 gap-4 p-6 rounded-xl bg-card/50 backdrop-blur-sm border border-border/50">
                <div className="space-y-4">
                  <div>
                    <p className="text-sm text-muted-foreground mb-1">Rent (48 hours)</p>
                    <p className="text-3xl font-bold text-secondary">5 FLOW</p>
                  </div>
                  <Button className="w-full gap-2 bg-secondary hover:bg-secondary/90 text-secondary-foreground">
                    <Play className="h-5 w-5" fill="currentColor" />
                    Rent Now
                  </Button>
                </div>

                <div className="space-y-4">
                  <div>
                    <p className="text-sm text-muted-foreground mb-1">Buy (Own Forever)</p>
                    <p className="text-3xl font-bold text-primary">15 FLOW</p>
                  </div>
                  <Button className="w-full gap-2 bg-gradient-neon shadow-neon">
                    <ShoppingCart className="h-5 w-5" />
                    Buy NFT
                  </Button>
                </div>
              </div>

              {/* Blockchain Info */}
              <div className="space-y-4 p-6 rounded-xl bg-card/30 backdrop-blur-sm border border-border/50">
                <h3 className="text-lg font-semibold flex items-center gap-2">
                  <Shield className="h-5 w-5 text-primary" />
                  Blockchain Verification
                </h3>
                <div className="space-y-3 text-sm">
                  <div className="flex items-start gap-3">
                    <Hash className="h-5 w-5 text-muted-foreground mt-0.5" />
                    <div>
                      <p className="font-medium mb-1">Content Hash</p>
                      <p className="text-muted-foreground font-mono break-all">
                        QmX4k9...8h2Pq (verified on IPFS)
                      </p>
                    </div>
                  </div>
                  <div className="flex items-start gap-3">
                    <Wallet className="h-5 w-5 text-muted-foreground mt-0.5" />
                    <div>
                      <p className="font-medium mb-1">Creator Wallet</p>
                      <p className="text-muted-foreground font-mono break-all">
                        0x1234...5678 (verified)
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default MovieDetail;
