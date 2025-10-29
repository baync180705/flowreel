import { getLangChainTools } from "@coinbase/agentkit-langchain";
import { MemorySaver } from "@langchain/langgraph";
import { createReactAgent } from "@langchain/langgraph/prebuilt";
import { ChatOpenAI } from "@langchain/openai";
import { prepareAgentkitAndWalletProvider } from "./prepare-agentkit";
import { VideoIntelligenceServiceClient,protos } from "@google-cloud/video-intelligence";
import { DynamicTool } from "@langchain/core/tools";

/**
 * Agent Configuration Guide
 *
 * This file handles the core configuration of your AI agent's behavior and capabilities.
 *
 * Key Steps to Customize Your Agent:
 *
 * 1. Select your LLM:
 *    - Modify the `ChatOpenAI` instantiation to choose your preferred LLM
 *    - Configure model parameters like temperature and max tokens
 *
 * 2. Instantiate your Agent:
 *    - Pass the LLM, tools, and memory into `createReactAgent()`
 *    - Configure agent-specific parameters
 */

// The agent
let agent: ReturnType<typeof createReactAgent>;

// Instantiate the Google Video Client
// This client will automatically find your credentials from the .env variable
const videoClient = new VideoIntelligenceServiceClient();

// Get the Likelihood enum from the protos
const Likelihood = protos.google.cloud.videointelligence.v1.Likelihood;

// Define the likelihood states that we consider "unsafe" using the numeric enum
const UNSAFE_LIKELIHOODS = [
  Likelihood.LIKELY,       // The number 4
  Likelihood.VERY_LIKELY,  // The number 5
  "LIKELY",                // The string "LIKELY"
  "VERY_LIKELY",           // The string "VERY_LIKELY"
];

/**
 * Creates a new LangChain tool for analyzing video content.
 * This tool calls the Google Video Intelligence API.
 */
function createVideoAnalysisTool(): DynamicTool {
  return new DynamicTool({
    name: "google_video_analyzer",
    description: `
      Analyzes a video for explicit content to determine if it is "suitable for kids under 18".
      Input must be a Google Cloud Storage (GCS) path (e.g., "gs://my-bucket/my-video.mp4").
      Returns a simple string: "SAFE" or "UNSAFE".
    `,
    func: async (gcsUri: string) => {
      try {
        if (!gcsUri.startsWith("gs://")) {
          return "Error: Invalid input. Must be a Google Cloud Storage path starting with 'gs://'.";
        }

        console.log(`[VideoTool] Analyzing: ${gcsUri}`);
        
        const features: protos.google.cloud.videointelligence.v1.Feature[] = [
          protos.google.cloud.videointelligence.v1.Feature
            .EXPLICIT_CONTENT_DETECTION,
        ];

        const [operation] = await videoClient.annotateVideo({
          inputUri: gcsUri,
          features: features,
        });

        console.log("[VideoTool] Waiting for video analysis to complete...");
        const [result] = await operation.promise();

        const annotations = result.annotationResults?.[0];
        const explicitFrames = annotations?.explicitAnnotation?.frames;

        if (!explicitFrames || explicitFrames.length === 0) {
          console.log(
            "[VideoTool] No explicit content data found. Defaulting to SAFE.",
          );
          return "SAFE";
        }

        // Check every frame annotation for unsafe content
        for (const frame of explicitFrames) {
if (
            frame.pornographyLikelihood &&
            UNSAFE_LIKELIHOODS.includes(frame.pornographyLikelihood)
          ) {
            const time = frame.timeOffset?.seconds || "N/A";
            console.log(
              `[VideoTool] Unsafe content found at ${time}s. Likelihood: ${frame.pornographyLikelihood}`,
            );
            return "UNSAFE";
          }
        }

        console.log("[VideoTool] Analysis complete. No explicit content found.");
        return "SAFE";
      } catch (error) {
        console.error("Error in video analysis tool:", error);
      if (error instanceof Error) {
          return `Error analyzing video: ${error.message}`;
        }
        // Handle cases where the thrown error is not an Error object
        return `Error analyzing video: ${String(error)}`;      
      }
    },
  });
}
/**
 * Initializes and returns an instance of the AI agent.
 * If an agent instance already exists, it returns the existing one.
 *
 * @function getOrInitializeAgent
 * @returns {Promise<ReturnType<typeof createReactAgent>>} The initialized AI agent.
 *
 * @description Handles agent setup
 *
 * @throws {Error} If the agent initialization fails.
 */
export async function createAgent(): Promise<ReturnType<typeof createReactAgent>> {
  // If agent has already been initialized, return it
  if (agent) {
    return agent;
  }

  if (!process.env.OPENAI_API_KEY) {
    throw new Error("I need an OPENAI_API_KEY in your .env file to power my intelligence.");
  }

  const { agentkit, walletProvider } = await prepareAgentkitAndWalletProvider();

  try {
    // Initialize LLM: https://platform.openai.com/docs/models#gpt-4o
    const llm = new ChatOpenAI({ model: "gpt-4o-mini" });

// Get the standard AgentKit (blockchain) tools
    const agentKitTools = await getLangChainTools(agentkit);

    // Create our new custom video tool
    const videoTool = createVideoAnalysisTool();

    // Combine all tools into one array
    const tools = [...agentKitTools, videoTool];
    const memory = new MemorySaver();

    // Initialize Agent
    const canUseFaucet = walletProvider.getNetwork().networkId == 'flow-testnet';
    const faucetMessage = `If you ever need funds, you can request them from the faucet.`;
    const cantUseFaucetMessage = `If you need funds, you can provide your wallet details and request funds from the user.`;
    
    const flowContextMessage = canUseFaucet
      ? `
      You are now operating on the Flow blockchain testnet using a Viem wallet. Flow is a fast, decentralized, and
      developer-friendly blockchain designed for NFTs, games, and apps. 

      Key facts about Flow:
      - Flow uses a proof-of-stake consensus mechanism
      - The native token is FLOW
      - Flow has a unique multi-role architecture for high throughput
      - The testnet is EVM-compatible (works with MetaMask + Viem)
      - RPC URL: https://testnet.evm.nodes.onflow.org
      - Chain ID: 545

      Your wallet address is \${await walletProvider.getAddress()}.
    `
      : '';

    
    agent = createReactAgent({
      llm,
      tools, // Pass the combined tools array
      checkpointSaver: memory,
      messageModifier: `
        You are a helpful agent interacting with the Flow blockchain testnet using a Viem wallet.
        Flow testnet supports EVM, so you can use Ethereum-compatible tools.
        ${flowContextMessage}

        You also have a special tool named 'google_video_analyzer' that can detect explicit content
        in videos. You must be given a Google Cloud Storage (GCS) path (gs://...) to use it.

        Before your first action, check the wallet details. If you see a 5XX error, ask the user to try again later.
        If a task is unsupported, let the user know and point them to CDP SDK + AgentKit at:
        https://docs.cdp.coinbase.com or https://developers.flow.com.

        Be concise, helpful, and avoid repeating tool descriptions unless asked.
      `,
    });

    return agent;
  } catch (error) {
    console.error("Error initializing agent:", error);
    throw new Error("Failed to initialize agent");
  }
}
