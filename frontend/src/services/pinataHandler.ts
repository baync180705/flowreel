import axios from "axios"
import { PinataSDK, UploadResponse } from 'pinata';

const pinata: PinataSDK = new PinataSDK({
    pinataJwt: "",
    pinataGateway: import.meta.env.VITE_GATEWAY_URL
  })

export const uploadFilesToPinata = async (url : string, file: File) => {
    try {
        const upload: UploadResponse = await pinata.upload.public.file(file).url(url);
        if (upload.cid) {
            const ipfsLink: string = await pinata.gateways.public.convert(upload.cid)
            return ipfsLink;
        }
    } catch (err) {
        throw new Error(`Error uploading File to IPFS. Error - ${err}`);
    }  
}
