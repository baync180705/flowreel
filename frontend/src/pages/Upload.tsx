import { useState } from "react"
import { useFlowCurrentUser } from "@onflow/react-sdk"
import { Navbar } from "@/components/Navbar"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { requestTemporaryURL } from "@/services/gatwayHandler";
import { uploadFilesToPinata } from "@/services/pinataHandler"

const UploadMovie = () => {
  const { user, authenticate } = useFlowCurrentUser()

  const [movieTitle, setMovieTitle] = useState("")
  const [movieFile, setMovieFile] = useState<File | null>(null)
  const [thumbnailFile, setThumbnailFile] = useState<File | null>(null)
  const [description, setDescription] = useState<string>("")
  const [link, setLink] = useState<string | null>(null);
  const [loading, setLoading] = useState(false); 
  const [currentAction, setCurrentAction] = useState<string | null>(null);

  const isConnected = user?.loggedIn
  const userAddr = user?.addr

  const handleMovieChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files?.[0]) {
      setMovieFile(e.target.files[0])
    }
  }

  const handleThumbnailChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files?.[0]) {
      setThumbnailFile(e.target.files[0])
    }
  }

  const handleSubmit = async () => {
    if (!isConnected) {
      alert("Please connect wallet first!");
      return authenticate();
    }

    if (!movieTitle || !movieFile || !thumbnailFile) {
      alert("Please fill all fields");
      return;
    }

    console.log("Wallet Connected:", userAddr);
    console.log("Movie:", movieTitle);
    console.log("Thumbnail:", thumbnailFile.name);
    console.log("Description:", description);

    console.log("Ready to upload and mint NFT");

    const URL: string = await requestTemporaryURL();
    if (!URL) {
      alert("Failed to fetch upload URL, Please try again!");
      return;
    }

    const files: File[] = [movieFile, thumbnailFile];
    setCurrentAction("The Movie is getting uploaded...");
    setLoading(true);
    try {
      for await (const { fileName, ipfsLink } of uploadFilesToPinata(URL, files)) {
        if (fileName === movieFile.name) {
          setCurrentAction("The Thumbnail is getting uploaded...");
          setLink(ipfsLink);
        } 
        console.log(`Uploaded ${fileName} to IPFS: ${ipfsLink}`);
      }

      console.log("All files uploaded successfully!");
      setCurrentAction(null);
    } catch (err) {
      console.error("Error during upload:", err);
      alert("An error occurred during the upload process. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-background">
      <Navbar />

      <main className="pt-24 px-4 max-w-3xl mx-auto">
        <h1 className="text-3xl font-bold mb-6">
          Upload & Mint <span className="bg-gradient-neon bg-clip-text text-transparent">Movie NFT</span>
        </h1>

        {/* Wallet Connect State */}
        {!isConnected ? (
          <div className="mb-6 p-4 border border-primary/40 rounded-lg text-center">
            <p className="mb-3 text-muted-foreground">
              Connect your wallet to upload movies
            </p>
            <Button onClick={authenticate} className="bg-gradient-neon">
              Connect Wallet
            </Button>
          </div>
        ) : (
          <p className="mb-4 text-green-500 text-sm font-medium">
            Wallet: {userAddr}
          </p>
        )}

        <div className="space-y-6 bg-card/40 border border-border/50 backdrop-blur-md p-6 rounded-xl">
          <div>
            <Label>Movie Title</Label>
            <Input
              type="text"
              placeholder="Enter movie title"
              value={movieTitle}
              onChange={(e) => setMovieTitle(e.target.value)}
            />
          </div>

          <div>
            <Label>Movie File</Label>
            <Input
              type="file"
              accept="video/*"
              onChange={handleMovieChange}
            />
          </div>

          <div>
            <Label>Thumbnail Image</Label>
            <Input
              type="file"
              accept="image/*"
              onChange={handleThumbnailChange}
            />
          </div>

          <div>
            <Label>Description</Label>
            <textarea
              placeholder="Enter movie description..."
              className="w-full rounded-md bg-background p-3 border border-border/50"
              rows={4}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
            />
          </div>

          <Button
            size="lg"
            disabled={!isConnected && loading}
            className={`bg-gradient-neon shadow-neon w-full ${loading ? "cursor-not-allowed" : ""}`}
            onClick={handleSubmit}
          >
            {loading ? (
            <div className="flex items-center justify-center">
              <svg
                className="animate-spin h-5 w-5 mr-2 text-white"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
              >
                <circle
                  className="opacity-25"
                  cx="12"
                  cy="12"
                  r="10"
                  stroke="currentColor"
                  strokeWidth="4"
                ></circle>
                <path
                  className="opacity-75"
                  fill="currentColor"
                  d="M4 12a8 8 0 018-8v8H4z"
                ></path>
              </svg>
              {currentAction || "Uploading..."}
            </div>
          ) : (
            "Upload and Mint NFT"
          )}
          </Button>
        </div>
        {link && (
          <div className="bg-gradient-neon bg-clip-text text-transparent">
            Your Movie has successfully been uploaded to IPFS ! 
            <a href = {link}> View File</a>
          </div>
        )}
      </main>
    </div>
  )
}

export default UploadMovie
