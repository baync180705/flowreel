import axios from "axios";

const SERVER_URL = import.meta.env.VITE_SERVER_URL;

export const requestTemporaryURL = async () => {
    try{
        const res = await axios.get(SERVER_URL);
        return res.data.url;
    } catch (err) {
        throw new Error(`Error fetching URL - ${err}`);
    }
}
