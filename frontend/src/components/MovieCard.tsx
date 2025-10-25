import { Play, Clock, ShoppingCart } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Link } from "react-router-dom";

interface MovieCardProps {
  id: string;
  title: string;
  thumbnail: string;
  creator: string;
  price: string;
  rentalPrice: string;
  duration: string;
  verified?: boolean;
}

export const MovieCard = ({
  id,
  title,
  thumbnail,
  creator,
  price,
  rentalPrice,
  duration,
  verified = true,
}: MovieCardProps) => {
  return (
    <Link to={`/movie/${id}`}>
      <div className="group relative overflow-hidden rounded-xl bg-card border border-border/50 transition-all hover:border-primary/50 hover:shadow-glow">
        <div className="aspect-[2/3] relative overflow-hidden">
          <img
            src={thumbnail}
            alt={title}
            className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
          />
          <div className="absolute inset-0 bg-gradient-cinema opacity-0 group-hover:opacity-100 transition-opacity" />
          
          <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
            <Button size="lg" className="gap-2 bg-gradient-neon shadow-neon">
              <Play className="h-5 w-5" fill="currentColor" />
              View Details
            </Button>
          </div>

          <div className="absolute top-3 right-3">
            <Badge variant="secondary" className="gap-1 bg-background/80 backdrop-blur-sm">
              <Clock className="h-3 w-3" />
              {duration}
            </Badge>
          </div>
        </div>

        <div className="p-4 space-y-3">
          <div>
            <h3 className="font-semibold text-lg mb-1 line-clamp-1">{title}</h3>
            <div className="flex items-center gap-2">
              <p className="text-sm text-muted-foreground">by {creator}</p>
              {verified && (
                <Badge variant="outline" className="text-xs border-verified text-verified">
                  Verified
                </Badge>
              )}
            </div>
          </div>

          <div className="flex items-center justify-between pt-2 border-t border-border/50">
            <div className="space-y-1">
              <p className="text-xs text-muted-foreground">Rent</p>
              <p className="font-semibold text-secondary">{rentalPrice} FLOW</p>
            </div>
            <div className="space-y-1 text-right">
              <p className="text-xs text-muted-foreground">Buy</p>
              <p className="font-semibold text-primary">{price} FLOW</p>
            </div>
          </div>
        </div>
      </div>
    </Link>
  );
};
