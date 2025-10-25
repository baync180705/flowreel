import { Navbar } from "@/components/Navbar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { CheckCircle2, Film, Upload } from "lucide-react";

const creators = [
  {
    name: "StellarFilms",
    avatar: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&h=200&fit=crop",
    moviesCount: 5,
    verified: true,
  },
  {
    name: "CyberCinema",
    avatar: "https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=200&h=200&fit=crop",
    moviesCount: 3,
    verified: true,
  },
  {
    name: "DeepBlueStudios",
    avatar: "https://images.unsplash.com/photo-1580489944761-15a19d654956?w=200&h=200&fit=crop",
    moviesCount: 7,
    verified: true,
  },
];

const Creators = () => {
  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      
      <main className="pt-24 pb-16">
        <div className="container mx-auto px-4">
          <div className="mb-12">
            <h1 className="text-4xl font-bold mb-2">
              Verified <span className="bg-gradient-neon bg-clip-text text-transparent">Creators</span>
            </h1>
            <p className="text-muted-foreground">Only trusted creators can upload content to our platform</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-16">
            {creators.map((creator) => (
              <div
                key={creator.name}
                className="p-6 rounded-xl bg-card/50 backdrop-blur-sm border border-border/50 hover:border-primary/50 transition-all"
              >
                <div className="flex items-start gap-4">
                  <img
                    src={creator.avatar}
                    alt={creator.name}
                    className="w-16 h-16 rounded-full border-2 border-primary/50"
                  />
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      <h3 className="font-semibold text-lg">{creator.name}</h3>
                      {creator.verified && (
                        <CheckCircle2 className="h-5 w-5 text-verified" />
                      )}
                    </div>
                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                      <Film className="h-4 w-4" />
                      <span>{creator.moviesCount} movies</span>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Become a Creator Section */}
          <div className="max-w-3xl mx-auto p-8 rounded-2xl bg-gradient-card backdrop-blur-sm border border-primary/20">
            <div className="text-center space-y-6">
              <div className="w-16 h-16 mx-auto rounded-full bg-primary/20 flex items-center justify-center">
                <Upload className="h-8 w-8 text-primary" />
              </div>
              
              <div>
                <h2 className="text-3xl font-bold mb-3">Become a Creator</h2>
                <p className="text-muted-foreground">
                  Want to share your movies on our platform? Apply for creator verification
                </p>
              </div>

              <div className="grid sm:grid-cols-3 gap-4 py-6">
                <div className="text-center">
                  <div className="w-12 h-12 mx-auto mb-2 rounded-full bg-card flex items-center justify-center text-xl font-bold">
                    1
                  </div>
                  <p className="text-sm text-muted-foreground">Submit Application</p>
                </div>
                <div className="text-center">
                  <div className="w-12 h-12 mx-auto mb-2 rounded-full bg-card flex items-center justify-center text-xl font-bold">
                    2
                  </div>
                  <p className="text-sm text-muted-foreground">DAO/Admin Review</p>
                </div>
                <div className="text-center">
                  <div className="w-12 h-12 mx-auto mb-2 rounded-full bg-card flex items-center justify-center text-xl font-bold">
                    3
                  </div>
                  <p className="text-sm text-muted-foreground">Start Uploading</p>
                </div>
              </div>

              <Button size="lg" className="bg-gradient-neon shadow-neon">
                Apply for Verification
              </Button>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Creators;
