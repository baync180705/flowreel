import { Navbar } from "@/components/Navbar";
import { MovieCard } from "@/components/MovieCard";
import { Input } from "@/components/ui/input";
import { Search } from "lucide-react";

const movies = [
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
  {
    id: "5",
    title: "Beyond Time",
    thumbnail: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=600&fit=crop",
    creator: "TemporalFilms",
    price: "20",
    rentalPrice: "7",
    duration: "2h 45m",
  },
  {
    id: "6",
    title: "Desert Mirage",
    thumbnail: "https://images.unsplash.com/photo-1473496169904-658ba7c44d8a?w=400&h=600&fit=crop",
    creator: "SandstormMedia",
    price: "14",
    rentalPrice: "5",
    duration: "2h 10m",
  },
];

const Browse = () => {
  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      
      <main className="pt-24 pb-16">
        <div className="container mx-auto px-4">
          <div className="mb-12 space-y-6">
            <div>
              <h1 className="text-4xl font-bold mb-2">
                Browse <span className="bg-gradient-neon bg-clip-text text-transparent">Movies</span>
              </h1>
              <p className="text-muted-foreground">Discover verified movies on the blockchain</p>
            </div>

            <div className="relative max-w-xl">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
              <Input
                placeholder="Search movies, creators..."
                className="pl-10 h-12 bg-card/50 border-border/50 focus:border-primary/50"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {movies.map((movie) => (
              <MovieCard key={movie.id} {...movie} />
            ))}
          </div>
        </div>
      </main>
    </div>
  );
};

export default Browse;
