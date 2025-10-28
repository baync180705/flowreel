import axios from "axios"
import { PinataSDK, UploadResponse } from 'pinata';

const pinata: PinataSDK = new PinataSDK({
    pinataJwt: import.meta.env.VITE_PINATA_JWT,
    pinataGateway: import.meta.env.VITE_GATEWAY_URL
  })

  export async function* uploadFilesToPinata (url: string, files: File[]) {
    try {
        for (const file of files) {
            console.log(`Uploading file: ${file.name}`);
            const upload: UploadResponse = await pinata.upload.public.file(file).url(url);
            if (upload.cid) {
                const ipfsLink: string = await pinata.gateways.public.convert(upload.cid);
                console.log(`File uploaded successfully: ${file.name}, IPFS Link: ${ipfsLink}`);
                yield { fileName: file.name, ipfsLink };
            } else {
                throw new Error(`Failed to upload file: ${file.name}`);
            }
        }
    } catch (err) {
        throw new Error(`Error uploading Files to IPFS. Error - ${err}`);
    }
};
