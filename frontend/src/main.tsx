import React from "react";
import { createRoot } from "react-dom/client";
import { FlowProvider } from "@onflow/react-sdk";
import App from "./App";
import "./index.css";

createRoot(document.getElementById("root")!).render(
    <FlowProvider
        config={{
            accessNodeUrl: "https://access-testnet.onflow.org",
            flowNetwork: "testnet",
            appDetailTitle: "flowreel",
            appDetailIcon: "https://example.com/icon.png",
            appDetailDescription: "A decentralized app on Flow",
            appDetailUrl: "https://myapp.com",
            discoveryWallet: "https://fcl-discovery.onflow.org/testnet/authn", 
            discoveryAuthnEndpoint: "https://fcl-discovery.onflow.org/api/testnet/authn", 
        }}
    >
        <App />
    </FlowProvider>
);
