import formidable from 'formidable';
import fs from 'fs';
import os from 'os';
import path from 'path';
import axios from 'axios';
import FormData from 'form-data';

export const config = {
  api: {
    bodyParser: false, 
  },
};

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // os tmp folder
  const form = formidable({
    uploadDir: os.tmpdir(),
    keepExtensions: true,
    multiples: true,
  });

  let fields, files;
  try {
    [fields, files] = await new Promise((resolve, reject) => {
      form.parse(req, (err, flds, fls) => {
        if (err) reject(err);
        else resolve([flds, fls]);
      });
    });
  } catch (err) {
    console.error('Form parse error:', err);
    return res.status(500).json({ error: 'Form parse error' });
  }

  const textValue = Array.isArray(fields.text) ? fields.text[0] : fields.text;
  if (!textValue) {
    return res.status(400).json({ error: 'No text provided' });
  }

  const tempPath = path.join(os.tmpdir(), 'comment.txt');
  fs.writeFileSync(tempPath, textValue, 'utf-8');

  const formData = new FormData();

  formData.append('file', fs.createReadStream(tempPath), {
    filename: 'comment.txt',
  });

  try {
    // upload to pinata
    const pinataRes = await axios.post(
      'https://api.pinata.cloud/pinning/pinFileToIPFS',
      formData,
      {
        maxBodyLength: Infinity,
        headers: {
          // merge formData.getHeaders()
          ...formData.getHeaders(),
          Authorization: `Bearer ${process.env.PINATA_JWT}`,
        },
      }
    );

    // TODO: CID
    const { IpfsHash } = pinataRes.data;

    return res.status(200).json({
      cid: IpfsHash,
      gateway: `https://gateway.pinata.cloud/ipfs/${IpfsHash}`,
      publicGateway: `https://ipfs.io/ipfs/${IpfsHash}`,
    });
  } catch (error) {
    const pinataError = error.response?.data || error.message;
    console.error('Pinata upload error:', pinataError);
    return res.status(500).json({ error: 'Pinata upload failed' });
  } finally {
    if (fs.existsSync(tempPath)) {
      fs.unlinkSync(tempPath);
    }
  }
}
