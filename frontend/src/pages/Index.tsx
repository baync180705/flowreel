import { Navbar } from "@/components/Navbar";
import { Hero } from "@/components/Hero";
import { HowItWorks } from "@/components/HowItWorks";
import { MovieCard } from "@/components/MovieCard";
import { Button } from "@/components/ui/button";
import { ArrowRight } from "lucide-react";

const featuredMovies = [
  {
    id: "1",
    title: "Cosmic Odyssey",
    thumbnail: "https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=400&h=600&fit=crop",
    creator: "StellarFilms",
    price: "15",
    rentalPrice: "5",
    duration: "2h 15m",
  },
  {
    id: "2",
    title: "Neon Dreams",
    thumbnail: "https://images.unsplash.com/photo-1485846234645-a62644f84728?w=400&h=600&fit=crop",
    creator: "CyberCinema",
    price: "12",
    rentalPrice: "4",
    duration: "1h 50m",
  },
  {
    id: "3",
    title: "Ocean's Whisper",
    thumbnail: "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=400&h=600&fit=crop",
    creator: "DeepBlueStudios",
    price: "18",
    rentalPrice: "6",
    duration: "2h 30m",
  },
  {
    id: "4",
    title: "Urban Legends",
    thumbnail: "https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=400&h=600&fit=crop",
    creator: "CityTales",
    price: "10",
    rentalPrice: "3",
    duration: "1h 45m",
  },
];

const Index = () => {
  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <Hero />
      <HowItWorks />
      
      {/* Featured Movies Section */}
      <section className="py-24 relative">
        <div className="container mx-auto px-4">
          <div className="flex items-center justify-between mb-12">
            <div>
              <h2 className="text-4xl font-bold mb-2">
                Featured <span className="bg-gradient-neon bg-clip-text text-transparent">Movies</span>
              </h2>
              <p className="text-muted-foreground">Discover the latest verified releases</p>
            </div>
            <Button variant="outline" className="gap-2 border-primary/50 hover:bg-primary/10">
              View All
              <ArrowRight className="h-4 w-4" />
            </Button>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {featuredMovies.map((movie) => (
              <MovieCard key={movie.id} {...movie} />
            ))}
          </div>
        </div>
      </section>
    </div>
  );
};

export default Index;
