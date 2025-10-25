import { Film, Wallet, User, Upload } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Link } from "react-router-dom";

export const Navbar = () => {
  return (
    <nav className="fixed top-0 left-0 right-0 z-50 border-b border-border/50 bg-background/80 backdrop-blur-xl">
      <div className="container mx-auto px-4">
        <div className="flex h-16 items-center justify-between">
          <Link to="/" className="flex items-center gap-2 group">
            <div className="relative">
              <Film className="h-8 w-8 text-primary transition-transform group-hover:scale-110" />
              <div className="absolute inset-0 blur-lg bg-primary/30 group-hover:bg-primary/50 transition-colors" />
            </div>
            <span className="text-xl font-bold bg-gradient-neon bg-clip-text text-transparent">
              FlowReel
            </span>
          </Link>

          <div className="hidden md:flex items-center gap-6">
            <Link to="/browse" className="text-sm font-medium text-foreground/80 hover:text-foreground transition-colors">
              Browse
            </Link>
            <Link to="/creators" className="text-sm font-medium text-foreground/80 hover:text-foreground transition-colors">
              Creators
            </Link>
            <Link to="/my-nfts" className="text-sm font-medium text-foreground/80 hover:text-foreground transition-colors">
              My NFTs
            </Link>
          </div>

          <div className="flex items-center gap-3">
            <Button variant="ghost" size="icon" className="relative">
              <User className="h-5 w-5" />
            </Button>
            <Button className="gap-2 bg-gradient-neon hover:shadow-neon transition-all">
              <Wallet className="h-4 w-4" />
              <span className="hidden sm:inline">Connect Wallet</span>
            </Button>
          </div>
        </div>
      </div>
    </nav>
  );
};
