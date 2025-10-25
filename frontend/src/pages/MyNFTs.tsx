import { Navbar } from "@/components/Navbar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Play, Clock, Infinity } from "lucide-react";

const nfts = [
  {
    id: "1",
    title: "Cosmic Odyssey",
    thumbnail: "https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=400&h=600&fit=crop",
    type: "owned",
    purchaseDate: "2024-01-15",
  },
  {
    id: "2",
    title: "Neon Dreams",
    thumbnail: "https://images.unsplash.com/photo-1485846234645-a62644f84728?w=400&h=600&fit=crop",
    type: "rental",
    expiresIn: "24 hours",
    purchaseDate: "2024-01-20",
  },
];

const MyNFTs = () => {
  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      
      <main className="pt-24 pb-16">
        <div className="container mx-auto px-4">
          <div className="mb-12">
            <h1 className="text-4xl font-bold mb-2">
              My <span className="bg-gradient-neon bg-clip-text text-transparent">MovieNFTs</span>
            </h1>
            <p className="text-muted-foreground">Your collection of owned and rented movies</p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {nfts.map((nft) => (
              <div
                key={nft.id}
                className="group relative overflow-hidden rounded-xl bg-card border border-border/50 transition-all hover:border-primary/50 hover:shadow-glow"
              >
                <div className="aspect-[2/3] relative overflow-hidden">
                  <img
                    src={nft.thumbnail}
                    alt={nft.title}
                    className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
                  />
                  <div className="absolute inset-0 bg-gradient-cinema opacity-0 group-hover:opacity-100 transition-opacity" />
                  
                  <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                    <Button size="lg" className="gap-2 bg-gradient-neon shadow-neon">
                      <Play className="h-5 w-5" fill="currentColor" />
                      Watch Now
                    </Button>
                  </div>

                  <div className="absolute top-3 right-3">
                    {nft.type === "owned" ? (
                      <Badge className="gap-1 bg-primary text-primary-foreground">
                        <Infinity className="h-3 w-3" />
                        Owned
                      </Badge>
                    ) : (
                      <Badge variant="secondary" className="gap-1 bg-secondary text-secondary-foreground">
                        <Clock className="h-3 w-3" />
                        {nft.expiresIn}
                      </Badge>
                    )}
                  </div>
                </div>

                <div className="p-4 space-y-2">
                  <h3 className="font-semibold text-lg line-clamp-1">{nft.title}</h3>
                  <p className="text-sm text-muted-foreground">
                    Added {new Date(nft.purchaseDate).toLocaleDateString()}
                  </p>
                </div>
              </div>
            ))}
          </div>

          {nfts.length === 0 && (
            <div className="text-center py-20">
              <p className="text-xl text-muted-foreground mb-4">No MovieNFTs yet</p>
              <Button className="bg-gradient-neon">Browse Movies</Button>
            </div>
          )}
        </div>
      </main>
    </div>
  );
};

export default MyNFTs;
